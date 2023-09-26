use std::{
    collections::{HashMap, HashSet, VecDeque},
    fmt,
};

use nom::{
    bytes::complete::tag,
    character::complete::newline,
    combinator::map,
    multi::{many1, separated_list1},
    number::complete::recognize_float,
    sequence::terminated,
    IResult,
};

pub fn part_one(input: &str) -> Option<u32> {
    let voxels = Voxel::to_set(parse(input).unwrap().1);
    let mut area = 0;
    for voxel in &voxels {
        let mut open = voxel.neighbors();
        open.retain(|v| !voxels.contains(v));
        area += open.len();
    }
    Some(area.try_into().unwrap())
}

pub fn part_two(input: &str) -> Option<u32> {
    let voxels: HashSet<Voxel> = Voxel::to_set(parse(input).unwrap().1);
    let mut steam: HashSet<Voxel> =
        voxels
            .iter()
            .flat_map(|v| v.neighbors())
            .fold(HashSet::new(), |mut acc, v| {
                if !voxels.contains(&v) {
                    acc.insert(v);
                }
                acc
            });

    let bounds = Voxel::get_bounds(&voxels);
    let mut cache: HashMap<Voxel, bool> = HashMap::new();

    for voxel in steam.clone().iter() {
        if voxel.pocketed(&voxels, &bounds, &mut cache) {
            steam.remove(voxel);
        }
    }

    let mut area = 0;
    for voxel in &voxels {
        let mut open = voxel.neighbors();
        open.retain(|v| steam.contains(v));
        area += open.len();
    }

    Some(area.try_into().unwrap())
}

#[derive(Clone, Eq, Hash, PartialEq)]
struct Voxel(i32, i32, i32);

impl fmt::Debug for Voxel {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {}, {})", self.0, self.1, self.2)
    }
}

impl Voxel {
    fn new(x: i32, y: i32, z: i32) -> Voxel {
        Voxel(x, y, z)
    }

    fn to_set(vec: Vec<Voxel>) -> HashSet<Voxel> {
        vec.iter().fold(HashSet::new(), |mut acc, v| {
            acc.insert(v.clone());
            acc
        })
    }

    fn get_bounds(voxels: &HashSet<Voxel>) -> (Voxel, Voxel) {
        let mut min = Voxel::new(i32::MAX, i32::MAX, i32::MAX);
        let mut max = Voxel::new(i32::MIN, i32::MIN, i32::MIN);
        for voxel in voxels {
            min.0 = min.0.min(voxel.0);
            min.1 = min.1.min(voxel.1);
            min.2 = min.2.min(voxel.2);
            max.0 = max.0.max(voxel.0);
            max.1 = max.1.max(voxel.1);
            max.2 = max.2.max(voxel.2);
        }
        (min, max)
    }

    fn bounded(&self, bounds: &(Voxel, Voxel)) -> bool {
        let (min, max) = bounds;
        self.0 >= min.0 && self.0 <= max.0 && // x
        self.1 >= min.1 && self.1 <= max.1 && // y
        self.2 >= min.2 && self.2 <= max.2 // z
    }

    fn pocketed(
        &self,
        voxels: &HashSet<Voxel>,
        bounds: &(Voxel, Voxel),
        cache: &mut HashMap<Voxel, bool>,
    ) -> bool {
        if let Some(hit) = cache.get(self) {
            return *hit;
        } else if voxels.contains(self) || !self.bounded(bounds) {
            cache.insert(self.clone(), false);
            return false;
        }

        let mut seen: HashSet<Voxel> = HashSet::new();
        let mut queue: VecDeque<Voxel> = vec![self.clone()].into_iter().collect();

        while !queue.is_empty() {
            let voxel = queue.pop_front().unwrap();

            if voxels.contains(&voxel) || seen.contains(&voxel) {
                continue;
            }

            seen.insert(voxel.clone());

            for neighbor in voxel.neighbors() {
                if voxels.contains(&neighbor) || seen.contains(&neighbor) {
                    continue;
                }

                let mut result: Option<bool> = None;

                if let Some(hit) = cache.get(&neighbor) {
                    result = Some(*hit);
                } else if !neighbor.bounded(bounds) {
                    result = Some(false);
                }

                if let Some(pocketed) = result {
                    for previous in seen {
                        cache.insert(previous, pocketed);
                    }
                    for queued in queue {
                        cache.insert(queued, pocketed);
                    }
                    return pocketed;
                }

                queue.push_back(neighbor);
            }
        }

        for previous in seen {
            cache.insert(previous, true);
        }
        true
    }

    fn neighbors(&self) -> Vec<Voxel> {
        vec![
            Voxel::new(self.0 + 1, self.1, self.2),
            Voxel::new(self.0 - 1, self.1, self.2),
            Voxel::new(self.0, self.1 + 1, self.2),
            Voxel::new(self.0, self.1 - 1, self.2),
            Voxel::new(self.0, self.1, self.2 + 1),
            Voxel::new(self.0, self.1, self.2 - 1),
        ]
    }
}

fn parse(input: &str) -> IResult<&str, Vec<Voxel>> {
    many1(terminated(
        map(
            separated_list1(tag(","), recognize_float),
            |coords: Vec<&str>| {
                Voxel(
                    coords[0].parse().unwrap(),
                    coords[1].parse().unwrap(),
                    coords[2].parse().unwrap(),
                )
            },
        ),
        newline,
    ))(input)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 18);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 18);
        assert_eq!(part_one(&input), Some(64));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 18);
        assert_eq!(part_two(&input), Some(58));
    }

    #[test]
    fn test_voxel_bounds() {
        let input = advent_of_code::read_file("examples", 18);
        let voxels = Voxel::to_set(parse(&input).unwrap().1);
        let (min, max) = Voxel::get_bounds(&voxels);
        assert_eq!(min, Voxel(1, 1, 1));
        assert_eq!(max, Voxel(3, 3, 6));
    }

    #[test]
    fn test_voxel_pocketed() {
        let input = advent_of_code::read_file("examples", 18);
        let voxels = Voxel::to_set(parse(&input).unwrap().1);
        let bounds = Voxel::get_bounds(&voxels);
        let mut cache = HashMap::new();

        for voxel in vec![Voxel(3, 1, 2), Voxel(0, 2, 5), Voxel(3, 2, 1)] {
            assert!(!voxel.pocketed(&voxels, &bounds, &mut cache));
        }

        let trapped = Voxel::new(2, 2, 5);
        assert!(trapped.pocketed(&voxels, &bounds, &mut cache));
    }
}
