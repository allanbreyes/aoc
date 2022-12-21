use std::{
    cmp::{Ordering, PartialOrd},
    collections::HashMap,
};

const ROOT: &str = "root";
const HUMAN: &str = "humn";

pub fn part_one(input: &str) -> Option<i64> {
    let lookup = parse(input, false);
    Some(lookup[ROOT].eval(&lookup))
}

pub fn part_two(input: &str) -> Option<i64> {
    let mut lookup = parse(input, true);
    let value = bracket(&mut lookup);
    Some(value)
}

fn bracket(lookup: &mut Lookup) -> i64 {
    let (mut lo, mut hi) = (0, i64::MAX / 10_i64.pow(3));
    let mut value = lookup[HUMAN].eval(lookup);
    let mut delta = lookup[ROOT].eval(lookup);

    let probe = 10;
    let lower = simulate(lookup, value - probe);
    let upper = simulate(lookup, value + probe);
    let comparator: fn(&i64, &i64) -> bool = match lower.cmp(&upper) {
        Ordering::Less => PartialOrd::lt,
        Ordering::Greater => PartialOrd::gt,
        _ => panic!("window is too small"),
    };

    while delta != 0 {
        if comparator(&delta, &0) {
            lo = lo.max(value);
            value = value + (hi - value) / 2
        } else {
            hi = hi.min(value);
            value = value - (value - lo) / 2
        }

        delta = simulate(lookup, value);
    }

    value
}

fn simulate(lookup: &mut Lookup, value: i64) -> i64 {
    lookup.insert(HUMAN.to_string(), Operation::Id(value));
    lookup[ROOT].eval(lookup)
}

#[derive(Debug)]
enum Operation {
    Add(String, String),
    Sub(String, String),
    Mul(String, String),
    Div(String, String),
    Id(i64),
}

impl Operation {
    fn eval(&self, lookup: &Lookup) -> i64 {
        match &self {
            Self::Id(n) => *n,
            Self::Add(x, y) => {
                lookup.get(x).unwrap().eval(lookup) + lookup.get(y).unwrap().eval(lookup)
            }
            Self::Sub(x, y) => {
                lookup.get(x).unwrap().eval(lookup) - lookup.get(y).unwrap().eval(lookup)
            }
            Self::Mul(x, y) => {
                lookup.get(x).unwrap().eval(lookup) * lookup.get(y).unwrap().eval(lookup)
            }
            Self::Div(x, y) => {
                lookup.get(x).unwrap().eval(lookup) / lookup.get(y).unwrap().eval(lookup)
            }
        }
    }
}

type Lookup = HashMap<String, Operation>;

fn parse(input: &str, fix: bool) -> Lookup {
    input
        .trim()
        .lines()
        .map(|line| {
            let (name, rest) = line.split_once(": ").unwrap();
            let parts: Vec<&str> = rest.split(' ').collect();
            let operation = match parts[..] {
                [x, sym, y] => {
                    let mut operation = match sym {
                        "+" => Operation::Add,
                        "-" => Operation::Sub,
                        "*" => Operation::Mul,
                        "/" => Operation::Div,
                        _ => panic!("operation not supported"),
                    };
                    if fix && name == ROOT {
                        operation = Operation::Sub;
                    }
                    operation(x.to_string(), y.to_string())
                }
                [n] => Operation::Id(n.parse().unwrap()),
                _ => panic!("error parsing input"),
            };
            (name, operation)
        })
        .fold(HashMap::new(), |mut acc, (name, operation)| {
            acc.insert(name.to_string(), operation);
            acc
        })
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 21);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 21);
        assert_eq!(part_one(&input), Some(152));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 21);
        assert_eq!(part_two(&input), Some(301));
    }
}
