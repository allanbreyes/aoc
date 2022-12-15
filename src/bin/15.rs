use std::collections::HashSet;

use nom::{
    bytes::complete::tag,
    character::complete::newline,
    combinator::{map, map_res},
    multi::many1,
    number::complete::recognize_float,
    sequence::{delimited, pair, preceded, terminated, tuple},
    IResult,
};

pub fn part_one(input: &str) -> Option<usize> {
    let (_, data) = parse(input).expect("parsing failed");
    let exclusions = get_exclusions(data, 2000000);
    Some(exclusions)
}

pub fn part_two(input: &str) -> Option<i64> {
    let (_, data) = parse(input).expect("parsing failed");
    let frequency = find_beacon(data, 4000000);
    Some(frequency)
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
struct Pos {
    x: i32,
    y: i32,
}

impl Pos {
    fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    /// Manhattan distance
    fn distance(&self, other: &Pos) -> i32 {
        (self.x - other.x).abs() + (self.y - other.y).abs()
    }

    fn perimeter(&self, radius: usize) -> Vec<Pos> {
        (self.x - radius as i32..self.x + radius as i32)
            .map(|x| {
                let dy = radius as i32 - (x - self.x).abs();
                [Pos::new(x, self.y - dy), Pos::new(x, self.y + dy)]
            })
            .flatten()
            .collect()
    }
}

fn find_beacon(data: Vec<(Pos, Pos)>, max: i32) -> i64 {
    let min = 0;
    let mut distress: Option<Pos> = None;
    let mut rejected: HashSet<Pos> = HashSet::new();

    // Generate and test
    'sensor: for (sensor, beacon) in &data {
        // Assume that the distress beacon is just outside the perimeter, or
        // else there would be a non-unique solution
        let radius = sensor.distance(&beacon) as usize + 1;

        'candidate: for candidate in sensor.perimeter(radius) {
            if candidate.x < min || candidate.x > max || candidate.y < min || candidate.y > max {
                continue 'candidate;
            }

            if rejected.contains(&candidate) {
                continue 'candidate;
            }

            'other: for (other_sensor, other_beacon) in &data {
                if other_sensor == sensor {
                    continue 'other;
                }

                let other_radius = other_sensor.distance(&other_beacon);
                if other_sensor.distance(&candidate) <= other_radius {
                    rejected.insert(candidate);
                    continue 'candidate;
                }
            }

            distress = Some(candidate);
            break 'sensor;
        }
    }

    let distress = distress.expect("no distress beacon found");
    distress.x as i64 * 4_000_000 + distress.y as i64
}

fn get_exclusions(data: Vec<(Pos, Pos)>, y: i32) -> usize {
    // Assume a continuous range of x values. An earlier version used a HashSet
    // implementation to account for gaps, but it was slower. We could instead
    // create and merge intervals, but this works for the given inputs.
    let mut lo = i32::max_value();
    let mut hi = i32::min_value();
    for (sensor, beacon) in data {
        let dist = sensor.distance(&beacon) - (sensor.y - y).abs();
        if dist < 0 {
            continue;
        }
        lo = lo.min(sensor.x - dist);
        hi = hi.max(sensor.x + dist);
    }
    (hi - lo) as usize
}

fn parse_i32(input: &str) -> IResult<&str, i32> {
    map_res(recognize_float, str::parse::<i32>)(input)
}

fn parse(input: &str) -> IResult<&str, Vec<(Pos, Pos)>> {
    many1(terminated(
        map(
            tuple((
                preceded(
                    tag("Sensor at "),
                    pair(
                        delimited(tag("x="), parse_i32, tag(", ")),
                        delimited(tag("y="), parse_i32, tag(":")),
                    ),
                ),
                preceded(
                    tag(" closest beacon is at "),
                    pair(
                        delimited(tag("x="), parse_i32, tag(", ")),
                        delimited(tag("y="), parse_i32, tag("")),
                    ),
                ),
            )),
            |((sx, sy), (bx, by))| (Pos::new(sx, sy), Pos::new(bx, by)),
        ),
        newline,
    ))(input)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 15);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 15);
        let (_, data) = parse(&input).unwrap();
        assert_eq!(get_exclusions(data, 20), 26);
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 15);
        let (_, data) = parse(&input).unwrap();
        assert_eq!(find_beacon(data, 20), 56000011);
    }
}
