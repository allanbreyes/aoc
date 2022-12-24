use std::fmt::{Debug, Formatter, Result as FmtResult};

use pathfinding::prelude::dijkstra;

pub fn part_one(input: &str) -> Option<usize> {
    let grid: Grid = parse(input);
    let (_path, length) = shortest(&grid, &Pos(0, 1, 0), 300).expect("no path found");
    Some(length)
}

pub fn part_two(_input: &str) -> Option<u32> {
    None
}

const UP: u8 = 0b1000;
const RIGHT: u8 = 0b0100;
const DOWN: u8 = 0b0010;
const LEFT: u8 = 0b0001;

#[derive(Debug, Clone)]
enum Tile {
    Start,
    End,
    Wall,
    Open,
    Blizzard(u8),
}

impl Tile {
    fn has(&self, dir: u8) -> bool {
        match self {
            Tile::Blizzard(b) => b & dir != 0,
            _ => false,
        }
    }
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

        // Return early if we didn't map out the grid far enough or if success
        if t + 1 >= grids.len() || self.success(grids) {
            return vec![];
        }

        // Start with staying
        let mut candidates: Vec<Pos> = vec![Pos(self.0, self.1, t + 1)]; // Stay

        // Prune initial candidates
        // NOTE: apparently you can just *waltz* right through a blizzard. Let's
        // keep this here in the case that part 2 changes that.
        const WALTZ: bool = true;
        for (i, j, block) in [
            (self.0 as i32 - 1, self.1 as i32, DOWN),  // Up
            (self.0 as i32, self.1 as i32 + 1, LEFT),  // Right
            (self.0 as i32 + 1, self.1 as i32, UP),    // Down
            (self.0 as i32, self.1 as i32 - 1, RIGHT), // Left
        ] {
            if i < 0 || j < 0 {
                continue;
            }
            if !WALTZ && grids[t][i as usize][j as usize].has(block) {
                continue;
            }
            candidates.push(Pos(i as usize, j as usize, t + 1));
        }

        // Filter out blocked tiles
        candidates
            .iter()
            .filter_map(|p| {
                let tile = &grids[p.2][p.0][p.1];
                if matches!(tile, Tile::Start | Tile::Open | Tile::End) {
                    Some((p.clone(), 1))
                } else {
                    None
                }
            })
            .collect()
    }

    fn success(&self, grids: &Grids) -> bool {
        let tile = &grids[self.2][self.0][self.1];
        matches!(tile, Tile::End)
    }
}

fn shortest(init: &Grid, start: &Pos, max_t: usize) -> Option<(Vec<Pos>, usize)> {
    let mut grids: Grids = vec![init.clone()];
    for _ in 1..max_t {
        let next = tick(grids.last().unwrap());
        grids.push(next);
    }

    let result = dijkstra(
        start,
        |p: &Pos| p.successors(&grids),
        |p: &Pos| p.success(&grids),
    );

    let debug: Option<Pos> = None;
    if let Some(pos) = debug {
        draw(&grids[pos.2], (pos.0, pos.1));
        let successors: Vec<Pos> = pos
            .successors(&grids)
            .iter()
            .map(|(p, _)| p.clone())
            .collect();
        dbg!(&successors, pos.success(&grids));
        if successors.is_empty() {
            draw(&grids[pos.2 + 1], (successors[0].0, successors[0].1));
        }
    }

    result
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

fn draw(grid: &Grid, pos: (usize, usize)) {
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
