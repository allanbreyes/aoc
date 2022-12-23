use std::collections::HashMap;

pub fn part_one(input: &str) -> Option<usize> {
    let elves = parse(input);
    let map = simulate(elves, 10);
    // println!("== Final ==");
    // draw(&map);
    let elves = map.keys().cloned().collect::<Vec<_>>();
    let (min, max) = bounds(&elves);
    let squares = ((max.0 - min.0 + 1) * (max.1 - min.1 + 1)) as usize - elves.len();
    Some(squares)
}

pub fn part_two(_input: &str) -> Option<u32> {
    None
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
enum Dir { NW, N, NE, E, SE, S, SW, W }

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

fn simulate(elves: Vec<Pos>, rounds: usize) -> HashMap<Pos, Option<Pos>> {
    let mut map: HashMap<Pos, Option<Pos>> = elves.iter().map(|pos| (pos.clone(), None)).collect();
    for i in 0..rounds {
        let dir = Dir::robin(i);
        // println!("== Round {} {:?} ==", i, dir);
        // draw(&map);
        // println!();

        // First half: "check" phase
        let mut check: HashMap<Pos, Option<Pos>> = HashMap::new();
        let mut moves: HashMap<Pos, usize> = HashMap::new();
        for pos in map.keys() {
            check.insert(pos.clone(), None);

            if !pos.neighbors().iter().any(|adj| map.contains_key(adj)) {
                continue;
            }

            for dir in Dir::robin(i) {
                if !pos.adjacents(dir).iter().any(|adj| map.contains_key(adj)) {
                    let new = pos.to(dir);
                    check.insert(pos.clone(), Some(new));
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
        for (pos, next) in check {
            if next.is_some() && moves[&next.unwrap()] == 1 {
                map.insert(next.unwrap(), None);
            } else {
                map.insert(pos, None);
            }
        }
    }

    map
}

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
        .map(|(i, line)| {
            line.chars()
                .enumerate()
                .filter_map(|(j, c)| match c {
                    '#' => Some(Pos(i as i32, j as i32)),
                    _ => None,
                })
                .collect::<Vec<_>>()
        })
        .flatten()
        .collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 23);
    // let input = &advent_of_code::read_file("examples", 23);
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
        assert_eq!(part_two(&input), None);
    }
}
