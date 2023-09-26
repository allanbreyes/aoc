use std::collections::HashMap;

pub fn part_one(input: &str) -> Option<usize> {
    let elves = parse(input);
    let (map, _) = simulate(elves, 10);
    let elves = map.keys().cloned().collect::<Vec<_>>();
    let (min, max) = bounds(&elves);
    let squares = ((max.0 - min.0 + 1) * (max.1 - min.1 + 1)) as usize - elves.len();
    Some(squares)
}

pub fn part_two(input: &str) -> Option<usize> {
    let elves = parse(input);
    let (_, settled) = simulate(elves, 10_000);
    Some(settled + 1)
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
enum Dir {
    NW,
    N,
    NE,
    E,
    SE,
    S,
    SW,
    W,
}

impl Dir {
    fn robin(i: usize) -> Vec<Self> {
        let mut list = vec![Dir::N, Dir::S, Dir::W, Dir::E];
        list.rotate_left(i % 4);
        list
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
struct Pos(i32, i32);

impl Pos {
    fn adjacents(&self, dir: Dir) -> Vec<Pos> {
        match dir {
            Dir::N => vec![self.to(Dir::NW), self.to(Dir::N), self.to(Dir::NE)],
            Dir::E => vec![self.to(Dir::NE), self.to(Dir::E), self.to(Dir::SE)],
            Dir::S => vec![self.to(Dir::SE), self.to(Dir::S), self.to(Dir::SW)],
            Dir::W => vec![self.to(Dir::SW), self.to(Dir::W), self.to(Dir::NW)],
            _ => panic!("not implemented"),
        }
    }

    fn neighbors(&self) -> Vec<Pos> {
        vec![
            self.to(Dir::NW),
            self.to(Dir::N),
            self.to(Dir::NE),
            self.to(Dir::E),
            self.to(Dir::SE),
            self.to(Dir::S),
            self.to(Dir::SW),
            self.to(Dir::W),
        ]
    }

    fn to(&self, dir: Dir) -> Pos {
        let Pos(i, j) = self;
        let (i, j) = (*i, *j);
        match dir {
            Dir::NW => Pos(i - 1, j - 1),
            Dir::N => Pos(i - 1, j),
            Dir::NE => Pos(i - 1, j + 1),
            Dir::E => Pos(i, j + 1),
            Dir::SE => Pos(i + 1, j + 1),
            Dir::S => Pos(i + 1, j),
            Dir::SW => Pos(i + 1, j - 1),
            Dir::W => Pos(i, j - 1),
        }
    }
}

fn bounds(elves: &Vec<Pos>) -> (Pos, Pos) {
    let mut min = Pos(i32::max_value(), i32::max_value());
    let mut max = Pos(i32::min_value(), i32::min_value());
    for pos in elves {
        let Pos(i, j) = pos;
        min = Pos(min.0.min(*i), min.1.min(*j));
        max = Pos(max.0.max(*i), max.1.max(*j));
    }
    (min, max)
}

type Map = HashMap<Pos, Option<Pos>>;

fn simulate(elves: Vec<Pos>, rounds: usize) -> (Map, usize) {
    let mut map: Map = elves.iter().map(|pos| (*pos, None)).collect();
    let mut settled = 0;
    for i in 0..rounds {
        // First half: "check" phase
        let mut check: Map = HashMap::new();
        let mut moves: HashMap<Pos, usize> = HashMap::new();
        for pos in map.keys() {
            check.insert(*pos, None);

            if !pos.neighbors().iter().any(|adj| map.contains_key(adj)) {
                continue;
            }

            for dir in Dir::robin(i) {
                if !pos.adjacents(dir).iter().any(|adj| map.contains_key(adj)) {
                    let new = pos.to(dir);
                    check.insert(*pos, Some(new));
                    #[allow(clippy::map_entry)]
                    if moves.contains_key(&new) {
                        moves.insert(new, moves[&new] + 1);
                    } else {
                        moves.insert(new, 1);
                    }
                    break;
                }
            }
        }

        // Second half: "move" phase
        map = HashMap::new();
        let mut moved = false;
        for (pos, next) in check {
            match next {
                Some(next) if moves[&next] == 1 => {
                    map.insert(next, None);
                    moved = true;
                }
                _ => {
                    map.insert(pos, None);
                }
            }
        }

        if !moved {
            settled = i;
            break;
        }
    }

    (map, settled)
}

#[allow(dead_code)]
fn draw(map: &HashMap<Pos, Option<Pos>>) {
    let (min, max) = bounds(&map.keys().cloned().collect::<Vec<_>>());
    println!("  {:2} -> {}", min.0, max.0);
    for i in min.0..=max.0 {
        print!("{:2} ", i);
        for j in min.1..=max.1 {
            let pos = Pos(i, j);
            if map.contains_key(&pos) {
                print!("#");
            } else {
                print!(".");
            }
        }
        println!();
    }
}

fn parse(input: &str) -> Vec<Pos> {
    input
        .lines()
        .enumerate()
        .flat_map(|(i, line)| {
            line.chars()
                .enumerate()
                .filter_map(|(j, c)| match c {
                    '#' => Some(Pos(i as i32, j as i32)),
                    _ => None,
                })
                .collect::<Vec<_>>()
        })
        .collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 23);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 23);
        assert_eq!(part_one(&input), Some(110));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 23);
        assert_eq!(part_two(&input), Some(20));
    }
}
