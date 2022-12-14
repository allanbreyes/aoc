use std::collections::HashSet;
use std::fmt;

use nom::{
    bytes::complete::tag,
    character::complete::{newline, u32},
    combinator::map,
    multi::separated_list0,
    sequence::separated_pair,
    IResult,
};

pub fn part_one(input: &str) -> Option<usize> {
    let (_, paths) = parse(input).unwrap();
    let mut world = World::from_paths(paths);
    let mut converged = false;

    while !converged {
        (world, converged) = world.drop(false);
    }

    if input.lines().count() < 5 {
        world.draw(493, 504);
    }

    Some(world.sand.len())
}

pub fn part_two(input: &str) -> Option<usize> {
    let (_, paths) = parse(input).unwrap();
    let mut world = World::from_paths(paths);
    let mut converged = false;

    while !converged {
        (world, converged) = world.drop(true);
        if world.sand.len() % 10000 == 0 {
            println!("Dropped {} particles...", world.sand.len());
        }
    }

    if input.lines().count() < 5 {
        world.draw(485, 515);
    }

    Some(world.sand.len() + 1)
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
struct Pos {
    x: u32,
    y: u32,
}

impl Pos {
    fn new(x: u32, y: u32) -> Self {
        Self { x, y }
    }
}

impl fmt::Display for Pos {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{},{}", self.x, self.y)
    }
}

enum Check {
    Obstructed,
    OutOfBounds,
}

enum Move {
    Down,
    Left,
    Right,
}

impl Move {
    fn from(&self, pos: &Pos) -> Pos {
        match self {
            Self::Down => Pos::new(pos.x, pos.y + 1),
            Self::Left => Pos::new(pos.x - 1, pos.y + 1),
            Self::Right => Pos::new(pos.x + 1, pos.y + 1),
        }
    }
}

#[derive(Clone)]
struct World {
    origin: Pos,

    rocks: HashSet<Pos>,
    sand: HashSet<Pos>,

    max_y: u32,
}

impl World {
    /// Create a new world from a list of paths
    fn from_paths(paths: Vec<Vec<Pos>>) -> Self {
        let mut rocks = HashSet::new();
        for path in paths {
            for i in 0..path.len() - 1 {
                let (start, end) = (&path[i], &path[i + 1]);
                let (mut dx, mut dy) =
                    (end.x as i32 - start.x as i32, end.y as i32 - start.y as i32);
                while dx != 0 || dy != 0 {
                    if dx > 0 {
                        dx -= 1;
                    } else if dx < 0 {
                        dx += 1;
                    }
                    if dy > 0 {
                        dy -= 1;
                    } else if dy < 0 {
                        dy += 1;
                    }
                    rocks.insert(Pos::new(
                        (start.x as i32 + dx) as u32,
                        (start.y as i32 + dy) as u32,
                    ));
                }
            }
            rocks.insert(path.last().unwrap().clone());
        }

        let max_y = Self::get_bounds(rocks.clone());

        Self {
            origin: Pos::new(500, 0),
            rocks,
            sand: HashSet::new(),

            max_y,
        }
    }

    /// Get the bounds of the world
    fn get_bounds(positions: HashSet<Pos>) -> u32 {
        positions.iter().fold(0, |max_y, pos| max_y.max(pos.y)) + 1
    }

    /// Check if a position is occupied or out of bounds
    fn check(&self, pos: &Pos) -> Option<Check> {
        if pos.y > self.max_y {
            return Some(Check::OutOfBounds);
        }

        if self.rocks.contains(pos) || self.sand.contains(pos) {
            return Some(Check::Obstructed);
        }

        None
    }

    /// Drop a sand particle and return the new world state and if stable
    fn drop(&self, floor: bool) -> (Self, bool) {
        let mut pos = self.origin.clone();
        let mut fut = self.clone();

        let mut done = false;
        let mut converged = false;

        while !done {
            let mut moved = false;

            for m in &[Move::Down, Move::Left, Move::Right] {
                let next = m.from(&pos);
                if !floor {
                    // Part one mechanics
                    match (m, self.check(&next)) {
                        (Move::Down, Some(Check::OutOfBounds)) => {
                            converged = true;
                            done = true;
                            break;
                        }
                        (_, Some(_)) => continue,
                        (_, None) => {
                            pos = next;
                            moved = true;
                            break;
                        }
                    }
                } else {
                    // Part two mechanics
                    match (m, self.check(&next)) {
                        (_, Some(_)) => continue,
                        (_, None) => {
                            pos = next;
                            moved = true;
                            break;
                        }
                    }
                }
            }

            if !moved {
                done = true;
                if pos == self.origin {
                    converged = true;
                }
            }
        }

        if !converged {
            fut.sand.insert(pos.clone());
        }

        (fut, converged)
    }

    /// Draw the state of the world
    fn draw(&self, left: u32, right: u32) {
        let mut buffer = String::new();
        let max_y = self.max_y;
        let mut grid = vec![vec!['.'; (right - left + 1) as usize]; (max_y + 2) as usize];

        // Floor (or abyss)
        for x in left..=right {
            grid[(max_y + 1) as usize][(x - left) as usize] = '=';
        }

        // Rocks
        for rock in &self.rocks {
            grid[rock.y as usize][(rock.x - left) as usize] = '#';
        }

        // Sand
        grid[self.origin.y as usize][(self.origin.x - left) as usize] = '+';
        for particle in &self.sand {
            grid[particle.y as usize][(particle.x - left) as usize] = 'o';
        }

        // Draw
        for (i, row) in grid.iter().enumerate() {
            buffer.push_str(format!("{:2} ", i).as_str());
            for col in row {
                buffer.push(*col);
            }
            buffer.push('\n');
        }

        println!("{}", buffer);
    }
}

fn parse(input: &str) -> IResult<&str, Vec<Vec<Pos>>> {
    separated_list0(
        newline,
        separated_list0(
            tag(" -> "),
            map(separated_pair(u32, tag(","), u32), |(x, y)| Pos::new(x, y)),
        ),
    )(input.trim())
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 14);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 14);
        assert_eq!(part_one(&input), Some(24));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 14);
        assert_eq!(part_two(&input), Some(93));
    }

    #[test]
    fn test_parse() {
        let input = "1,2 -> 3,4\n5,6 -> 7,8\n";
        assert_eq!(
            parse(&input),
            Ok((
                "",
                vec![
                    vec![Pos::new(1, 2), Pos::new(3, 4)],
                    vec![Pos::new(5, 6), Pos::new(7, 8)],
                ]
            ))
        );
    }
}
