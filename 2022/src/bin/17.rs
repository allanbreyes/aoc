use std::fmt::{Debug, Formatter};

use anyhow::{bail, Result};

pub fn part_one(input: &str) -> Option<usize> {
    let jets = parse(input);
    Some(simulate(jets, 2022))
}

pub fn part_two(_input: &str) -> Option<u32> {
    // TODO: refactor Python script to Rust... Some Day(TM)
    None
}

type Point = (i32, i32);

#[derive(Clone)]
struct Matrix {
    data: Vec<Vec<u8>>,
}

impl Debug for Matrix {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        writeln!(f, "Matrix{:?}:", self.shape())?;
        for (i, row) in self.data.iter().rev().enumerate() {
            if i > 16 {
                break;
            }
            write!(f, "{:4} ", self.data.len() - i - 1)?;
            for cell in row {
                let char = match cell {
                    0 => '.',
                    1 => '#',
                    _ => panic!("unreachable"),
                };
                write!(f, "{}", char)?;
            }
            writeln!(f)?;
        }
        write!(f, "     ")?;
        for i in 0..self.data[0].len() {
            write!(f, "{}", i)?;
        }
        Ok(())
    }
}

impl Matrix {
    fn new(shape: (usize, usize), fill: Vec<u8>) -> Self {
        let (rows, cols) = shape;
        let mut data = vec![vec![0; cols]; rows];
        for (i, row) in data.iter_mut().enumerate() {
            for (j, cell) in row.iter_mut().enumerate() {
                *cell = fill[i * cols + j];
            }
        }

        Matrix { data }
    }

    fn grow(&mut self, amount: usize) {
        let (_, cols) = self.shape();
        self.data.extend(vec![vec![0; cols]; amount]);
    }

    fn height(&self) -> usize {
        for (i, row) in self.data.iter().rev().enumerate() {
            let i = self.data.len() - i;
            if row.iter().any(|&x| x == 1) {
                return i;
            }
        }
        0
    }

    fn overlay(&mut self, rock: &Rock, pos: Point, paint: bool) -> Result<bool> {
        let (rows, cols) = self.shape();
        let (row_offset, col_offset) = pos;
        for (i, j) in rock.points() {
            let i = i + row_offset;
            let j = j + col_offset;

            if i < 0 || i >= rows as i32 || j < 0 || j >= cols as i32 {
                bail!("out of bounds");
            }

            if self.data[i as usize][j as usize] == 1 {
                bail!("collision");
            }
        }

        if paint {
            for (i, j) in rock.points() {
                let i = i + row_offset;
                let j = j + col_offset;
                self.data[i as usize][j as usize] = 1;
            }
        }

        Ok(paint)
    }

    fn shape(&self) -> (usize, usize) {
        (self.data.len(), self.data[0].len())
    }
}

#[derive(Clone, Debug)]
enum Move {
    Left,
    Right,
    Down,
}

impl Move {
    fn apply(&self, pos: Point) -> Point {
        let (row, col) = pos;
        match self {
            Move::Left => (row, col - 1),
            Move::Right => (row, col + 1),
            Move::Down => (row - 1, col),
        }
    }
}

#[derive(Debug)]
enum Rock {
    Flat,
    Plus,
    RevL,
    Line,
    Box2,
}

impl Rock {
    fn emit(i: u32) -> Self {
        match i % 5 {
            0 => Rock::Flat,
            1 => Rock::Plus,
            2 => Rock::RevL,
            3 => Rock::Line,
            4 => Rock::Box2,
            _ => panic!("unreachable"),
        }
    }

    fn points(&self) -> Vec<Point> {
        let mut vec = Vec::new();
        for (i, row) in self.sprite().data.iter().enumerate() {
            for (j, cell) in row.iter().enumerate() {
                if *cell == 1 {
                    vec.push((i as i32, j as i32))
                }
            }
        }
        vec
    }

    fn sprite(&self) -> Matrix {
        match self {
            Rock::Flat => Matrix::new((1, 4), vec![1; 4]),
            Rock::Plus => Matrix::new((3, 3), vec![0, 1, 0, 1, 1, 1, 0, 1, 0]),
            Rock::RevL => Matrix::new((3, 3), vec![1, 1, 1, 0, 0, 1, 0, 0, 1]),
            Rock::Line => Matrix::new((4, 1), vec![1; 4]),
            Rock::Box2 => Matrix::new((2, 2), vec![1; 4]),
        }
    }
}

enum Mode {
    Falling,
    Pushing,
}

impl Mode {
    fn from(t: i32) -> Self {
        match t % 2 {
            0 => Mode::Pushing,
            1 => Mode::Falling,
            _ => panic!("unreachable"),
        }
    }
}

fn simulate(jets: Vec<Move>, rock_limit: u32) -> usize {
    let mut jets = jets.into_iter().cycle();
    let mut chamber = Matrix::new((7, 7), vec![0; 7 * 7]);

    // Initial conditions
    let mut mov: Move;
    let mut next: Point;
    let mut pos: Point = (chamber.height() as i32 + 3, 2);
    let mut rock: Rock = Rock::emit(0);
    let mut rocks: u32 = 1;
    let mut tick: i32 = 0;

    while rocks <= rock_limit {
        if rock_limit < 3 {
            let mut vis = chamber.clone();
            vis.overlay(&rock, pos, true).expect("paint failed");
            dbg!(&vis);
        }

        match Mode::from(tick) {
            Mode::Pushing => {
                mov = jets.next().unwrap();
                next = mov.apply(pos);
                if chamber.overlay(&rock, next, false).is_ok() {
                    pos = next
                }
            }
            Mode::Falling => {
                mov = Move::Down;
                next = mov.apply(pos);
                match chamber.overlay(&rock, next, false) {
                    Ok(_) => pos = next,
                    Err(_) => {
                        chamber.overlay(&rock, pos, true).expect("paint failed");
                        rock = Rock::emit(rocks);
                        rocks += 1;

                        pos = (chamber.height() as i32 + 3, 2);
                        let (row, _) = pos;
                        let (rows, _) = chamber.shape();
                        if row + 4 >= rows as i32 {
                            chamber.grow(4);
                        }

                        if rock_limit < 2022 {
                            let mut vis = chamber.clone();
                            vis.overlay(&rock, pos, true).expect("paint failed");
                            dbg!(vis);
                        }
                    }
                }
            }
        }
        tick += 1;
    }
    chamber.height()
}

fn parse(input: &str) -> Vec<Move> {
    input
        .trim()
        .chars()
        .map(|c| match c {
            '<' => Move::Left,
            '>' => Move::Right,
            _ => panic!("invalid input"),
        })
        .collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 17);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 17);
        assert_eq!(part_one(&input), Some(3068));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 17);
        assert_eq!(part_two(&input), None);
    }
}
