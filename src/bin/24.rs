use std::{
    fmt::{Debug, Formatter, Result as FmtResult},
    thread::sleep,
    time::Duration,
};

use pathfinding::prelude::dijkstra;

const ANIMATE: u64 = 25; // Frame delay in ms. Set to zero for no animation.

pub fn part_one(input: &str) -> Option<usize> {
    let init: Grid = parse(input);
    let grids = make_grids(&init, 300);
    let (_, cost) = shortest(&grids, &Pos(0, 1, 0), Tile::End).expect("no path found");
    Some(cost)
}

pub fn part_two(input: &str) -> Option<usize> {
    let init: Grid = parse(input);
    let grids = make_grids(&init, 1000);
    let (there, _) = shortest(&grids, &Pos(0, 1, 0), Tile::End).expect("no path found");
    let (back, _) = shortest(&grids, there.last().unwrap(), Tile::Start).expect("no path found");
    let (again, _) = shortest(&grids, back.last().unwrap(), Tile::End).expect("no path found");
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

    fn success(&self, grids: &Grids, goal: Tile) -> bool {
        let tile = &grids[self.2][self.0][self.1];
        tile == &goal
    }
}

fn shortest(grids: &Grids, start: &Pos, goal: Tile) -> Option<(Vec<Pos>, usize)> {
    let result = dijkstra(
        start,
        |p: &Pos| p.successors(grids),
        |p: &Pos| p.success(grids, goal),
    );

    if ANIMATE > 0 {
        if let Some((path, _)) = &result {
            for pos in path {
                let (r, c, t) = (pos.0, pos.1, pos.2);
                draw(&grids[t], (r, c), true);
                sleep(Duration::from_millis(ANIMATE as u64));
            }
        }
    }

    result
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

fn draw(grid: &Grid, pos: (usize, usize), clear: bool) {
    if clear {
        print!("\x1B[2J\x1B[1;1H");
    }
    for (i, row) in grid.iter().enumerate() {
        for (j, tile) in row.iter().enumerate() {
            print!(
                "{}",
                if pos == (i, j) {
                    "\x1b[91m☺\x1b[0m"
                } else {
                    match tile {
                        Tile::Start => "S",
                        Tile::End => "E",
                        Tile::Wall => "#",
                        Tile::Open => ".",
                        Tile::Blizzard(k) => match *k {
                            UP => "^",
                            RIGHT => ">",
                            DOWN => "v",
                            LEFT => "<",
                            _ => match k.count_ones() {
                                2 => "2",
                                3 => "3",
                                4 => "4",
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
    // let input = &advent_of_code::read_file("examples", 24);
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
        assert_eq!(part_two(&input), None);
    }
}
