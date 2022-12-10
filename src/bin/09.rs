use std::collections::HashSet;
use std::fmt;

pub fn part_one(input: &str) -> Option<usize> {
    let moves = parse(input);
    Some(simulate(moves, 2, 6, false))
}

pub fn part_two(input: &str) -> Option<usize> {
    let moves = parse(input);
    Some(simulate(moves, 10, 6, false))
}

fn simulate(moves: Vec<Move>, n: usize, offset: i32, debug: bool) -> usize {
    let mut knots: Vec<Position> = (0..n).map(|_| Position::new(offset, 0)).collect();
    let mut visited: HashSet<Position> = HashSet::new();

    for m in moves {
        let head = knots[0].clone();
        knots[0] = m.apply(&head);

        if debug {
            print!("{}\tH:{} ", m, knots[0]);
        }

        for i in 1..n {
            if !knots[i].is_adjacent(&knots[i-1]) {
                let next = &knots[i-1].adjacents()
                    .iter()
                    .filter(|p| p.is_adjacent(&knots[i])).cloned()
                    .collect::<Vec<_>>()
                    .first()
                    .unwrap()
                    .clone();
                knots[i] = next.clone();
            }

            if debug {
                print!("{}:{} ", i, knots[i]);
            }
        }

        visited.insert(knots[n-1].clone());
        if debug {
            println!("= {}", visited.len());
            print_frame(knots.clone(), 6);
        }
    }
    visited.len()
}

#[derive(Clone, Eq, Hash, PartialEq)]
struct Position {
    x: i32,
    y: i32,
}

impl Position {
    fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    fn adjacents(&self) -> Vec<Self> {
        vec![
            // Same position
            self.clone(), 

            // Cardinals
            Self::new(self.x, self.y + 1),
            Self::new(self.x, self.y - 1),
            Self::new(self.x + 1, self.y),
            Self::new(self.x - 1, self.y),

            // Diagonals
            Self::new(self.x + 1, self.y + 1),
            Self::new(self.x + 1, self.y - 1),
            Self::new(self.x - 1, self.y + 1),
            Self::new(self.x - 1, self.y - 1),
        ]
    }

    fn is_adjacent(&self, other: &Position) -> bool {
        self.adjacents().contains(other)
    }
}

impl fmt::Display for Position {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{},{}", self.x, self.y)
    }
}

struct Move {
    x: i32,
    y: i32,
}

impl Move {
    fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    /// Apply a move to a position, returning a new position
    fn apply(&self, position: &Position) -> Position {
        Position::new(position.x + self.x, position.y + self.y)
    }
    
    /// Naively deconstruct a move into a list of 1-step moves
    fn deconstruct(&self) -> Vec<Move> {
        let mut moves = Vec::new();
        let mut x = 0;
        let mut y = 0;
        while x != self.x || y != self.y {
            if x < self.x {
                moves.push(Move::new(1, 0));
                x += 1;
            } else if x > self.x {
                moves.push(Move::new(-1, 0));
                x -= 1;
            } else if y < self.y {
                moves.push(Move::new(0, 1));
                y += 1;
            } else if y > self.y {
                moves.push(Move::new(0, -1));
                y -= 1;
            } else {
                panic!("off by one?");
            }
        }
        moves
    }
}

impl fmt::Display for Move {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{},{}", self.x, self.y)
    }
}

fn parse(input: &str) -> Vec<Move> {
    input
    .lines()
    .map(|line| {
        let (direction, distance) = line.split_once(' ').unwrap();
        let distance = distance.parse::<i32>().unwrap();
        match direction {
            "U" => Move::new(-distance, 0),
            "D" => Move::new(distance, 0),
            "L" => Move::new(0, -distance),
            "R" => Move::new(0, distance),
            _ => panic!("unknown direction: {}", direction),
        }
    })
    .flat_map(|m| m.deconstruct())
    .collect()
}

fn print_frame(knots: Vec<Position>, len: usize) {
    let mut grid = vec![vec!['.'; len]; len];
    for (i, knot) in knots.iter().rev().enumerate() {
        let j = knots.len() - i - 1;
        grid[knot.x as usize][knot.y as usize] = match j {
            0 => 'H',
            _ => j.to_string().chars().next().unwrap(),
        }
    }
    for row in grid {
        for c in row {
            print!("{}", c);
        }
        println!();
    }
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 9);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 9);
        assert_eq!(part_one(&input), Some(13));

        let input = include_str!("../examples/09-50.txt");
        assert_eq!(part_one(input), Some(17));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 9);
        assert_eq!(part_two(&input), Some(1));

        println!("===");

        let input = "R 5\nU 8\nL 8\nD 3";
        assert_eq!(part_two(input), Some(4));
    }
}
