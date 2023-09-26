use std::{
    fmt::{Debug, Formatter, Result as FmtResult},
    thread::sleep,
    time::Duration,
};

use pathfinding::prelude::astar;

pub fn part_one(input: &str) -> Option<usize> {
    let init: Grid = parse(input);
    let grids = make_grids(&init, 300);
    let end = find_tile(&grids[0], Tile::End).expect("no end tile found");
    let (_, cost) = shortest(&grids, &Pos(0, 1, 0), end, false).expect("no path found");
    Some(cost)
}

pub fn part_two(input: &str) -> Option<usize> {
    let init: Grid = parse(input);
    let a = init.len() > 10;
    let grids = make_grids(&init, 1000);
    let start = find_tile(&grids[0], Tile::Start).expect("no start tile found");
    let end = find_tile(&grids[0], Tile::End).expect("no end tile found");
    let (there, _) = shortest(&grids, &Pos(0, 1, 0), end, a).expect("no path found");
    let (back, _) = shortest(&grids, there.last().unwrap(), start, a).expect("no path found");
    let (again, _) = shortest(&grids, back.last().unwrap(), end, a).expect("no path found");
    Some(again.last().unwrap().2 as usize)
}

const UP: u8 = 0b1000;
const RIGHT: u8 = 0b0100;
const DOWN: u8 = 0b0010;
const LEFT: u8 = 0b0001;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Tile {
    Start,
    End,
    Wall,
    Open,
    Blizzard(u8),
}

type Grid = Vec<Vec<Tile>>;
type Grids = Vec<Grid>;
type Pos2D = (usize, usize);

#[derive(Clone, PartialEq, Eq, Hash)]
struct Pos(usize, usize, usize);

impl Debug for Pos {
    fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
        write!(f, "Pos(r={}, c={}, t={})", self.0, self.1, self.2)
    }
}

impl Pos {
    fn successors(&self, grids: &Grids) -> Vec<(Pos, usize)> {
        let t = self.2;

        // Return early if we didn't map out the grid far enough
        if t + 1 >= grids.len() {
            return vec![];
        }

        // NOTE: apparently you can just *waltz* right through a blizzard!
        [
            (self.0 as i32, self.1 as i32),     // Stay
            (self.0 as i32 - 1, self.1 as i32), // Up
            (self.0 as i32, self.1 as i32 + 1), // Right
            (self.0 as i32 + 1, self.1 as i32), // Down
            (self.0 as i32, self.1 as i32 - 1), // Left
        ]
        .iter()
        .filter_map(|(i, j)| {
            if *i < 0
                || *j < 0
                || *i >= grids[t].len() as i32
                || *j >= grids[t][*i as usize].len() as i32
            {
                return None;
            }
            let p = Pos(*i as usize, *j as usize, t + 1);
            let tile = &grids[p.2][p.0][p.1];
            if matches!(tile, Tile::Start | Tile::Open | Tile::End) {
                Some((p, 1))
            } else {
                None
            }
        })
        .collect()
    }

    fn success(&self, goal: Pos2D) -> bool {
        let pos2d = (self.0, self.1);
        pos2d == goal
    }
}

fn shortest(grids: &Grids, start: &Pos, goal: Pos2D, animate: bool) -> Option<(Vec<Pos>, usize)> {
    let result = astar(
        start,
        |p: &Pos| p.successors(grids),
        |p: &Pos| heuristic(p, goal),
        |p: &Pos| p.success(goal),
    );

    if animate {
        if let Some((path, _)) = &result {
            print!("\x1B[2J\x1B[1;1H");
            for pos in path {
                let (r, c, t) = (pos.0, pos.1, pos.2);
                draw(&grids[t], (r, c), true);
                sleep(Duration::from_millis(10));
            }
        }
    }

    result
}

fn find_tile(grid: &Grid, tile: Tile) -> Option<Pos2D> {
    for (i, row) in grid.iter().enumerate() {
        for (j, col) in row.iter().enumerate() {
            if col == &tile {
                return Some((i, j));
            }
        }
    }
    None
}

fn heuristic(pos: &Pos, goal: Pos2D) -> usize {
    let pos2d = (pos.0, pos.1);
    (goal.0 as i32 - pos2d.0 as i32).unsigned_abs() as usize
        + (goal.1 as i32 - pos2d.1 as i32).unsigned_abs() as usize
}

fn make_grids(init: &Grid, max_t: usize) -> Grids {
    let mut grids: Grids = vec![init.clone()];
    for _ in 1..max_t {
        let next = tick(grids.last().unwrap());
        grids.push(next);
    }
    grids
}

fn tick(grid: &Grid) -> Grid {
    let mut next = grid.clone();
    let row_limit = grid.len() - 2;
    let col_limit = grid[0].len() - 2;
    for i in 1..=row_limit {
        for j in 1..=col_limit {
            let up = if i == 1 {
                &grid[row_limit][j]
            } else {
                &grid[i - 1][j]
            };
            let right = if j == col_limit {
                &grid[i][1]
            } else {
                &grid[i][j + 1]
            };
            let down = if i == row_limit {
                &grid[1][j]
            } else {
                &grid[i + 1][j]
            };
            let left = if j == 1 {
                &grid[i][col_limit]
            } else {
                &grid[i][j - 1]
            };

            let mut k: u8 = 0b0000;

            for (pos, dir) in vec![(up, DOWN), (right, LEFT), (down, UP), (left, RIGHT)].iter() {
                if let Tile::Blizzard(b) = pos {
                    if b & dir != 0 {
                        k += dir;
                    };
                }
            }

            next[i][j] = if k == 0 {
                Tile::Open
            } else {
                Tile::Blizzard(k)
            };
        }
    }
    next
}

fn draw(grid: &Grid, pos: Pos2D, clear: bool) {
    if clear {
        print!("\x1B[1;1H");
    }
    for (i, row) in grid.iter().enumerate() {
        for (j, tile) in row.iter().enumerate() {
            print!(
                "{}",
                if pos == (i, j) {
                    "\x1b[0;31m☺\x1b[0m"
                } else {
                    match tile {
                        Tile::Start => "\x1b[0;34mS\x1b[0m",
                        Tile::End => "\x1b[0;32mE\x1b[0m",
                        Tile::Wall => "#",
                        Tile::Open => " ",
                        Tile::Blizzard(k) => match *k {
                            UP => "\x1b[38;5;240m^\x1b[0m",
                            RIGHT => "\x1b[38;5;240m>\x1b[0m",
                            DOWN => "\x1b[38;5;240mv\x1b[0m",
                            LEFT => "\x1b[38;5;240m<\x1b[0m",
                            _ => match k.count_ones() {
                                2 => "\x1b[38;5;245m*\x1b[0m",
                                3 => "\x1b[38;5;250m%\x1b[0m",
                                4 => "\x1b[38;5;255m@\x1b[0m",
                                _ => panic!("too many blizzards: {}", k),
                            },
                        },
                    }
                }
            );
        }
        println!();
    }
}

fn parse(input: &str) -> Grid {
    let last = input.lines().count() - 1;
    input
        .lines()
        .enumerate()
        .map(|(i, line)| {
            line.chars()
                .map(move |c| match c {
                    '.' => {
                        if i == 0 {
                            Tile::Start
                        } else if i == last {
                            Tile::End
                        } else {
                            Tile::Open
                        }
                    }
                    '#' => Tile::Wall,
                    '^' => Tile::Blizzard(UP),
                    '>' => Tile::Blizzard(RIGHT),
                    'v' => Tile::Blizzard(DOWN),
                    '<' => Tile::Blizzard(LEFT),
                    _ => panic!("Unknown tile: {}", c),
                })
                .collect()
        })
        .collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 24);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 24);
        assert_eq!(part_one(&input), Some(18));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 24);
        assert_eq!(part_two(&input), Some(54));
    }
}
