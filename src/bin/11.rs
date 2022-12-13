use std::collections::VecDeque;
use std::env;
use std::str::FromStr;

pub fn part_one(input: &str) -> Option<u64> {
    let mut monkeys = parse(input);
    let m = find_mod(&monkeys);
    for _ in 0..20 {
        monkeys = simulate(&monkeys, true, m);
    }
    Some(calculate(&monkeys))
}

pub fn part_two(input: &str) -> Option<u64> {
    let mut monkeys = parse(input);
    let m = find_mod(&monkeys);
    for i in 0..10000 {
        monkeys = simulate(&monkeys, false, m);
        if (i == 0 || i == 19 || (i + 1) % 1000 == 0) && env::var("DEBUG").is_ok() {
            println!("== After round {} ==", i + 1);
            pretty_print(monkeys.clone());
        }
    }
    Some(calculate(&monkeys))
}

#[derive(Clone, Debug)]
struct Monkey {
    items: VecDeque<u64>,
    operation: Operation,
    test: Test,
    pass: usize,
    fail: usize,
    inspects: usize,
}

#[derive(Clone, Copy, Debug)]
enum Operation {
    Add(u64),
    Div(u64),
    Mul(u64),
    Sq,
}

impl FromStr for Operation {
    type Err = ();

    fn from_str(input: &str) -> Result<Self, Self::Err> {
        let tokens = input.split(' ').collect::<Vec<_>>();
        match tokens[..] {
            ["new", "=", "old", "*", "old"] => Ok(Operation::Sq),
            ["new", "=", "old", "*", n] => Ok(Operation::Mul(n.parse().unwrap())),
            ["new", "=", "old", "+", n] => Ok(Operation::Add(n.parse().unwrap())),
            _ => Err(()),
        }
    }
}

impl Operation {
    fn apply(&self, value: u64, m: u64) -> u64 {
        match self {
            Operation::Add(x) => (value + x) % m,
            Operation::Div(x) => (value / x) % m,
            Operation::Mul(x) => (value * x) % m,
            Operation::Sq => (value * value) % m,
        }
    }

    fn get_factor(&self) -> Option<u64> {
        match self {
            Operation::Mul(x) => Some(*x),
            Operation::Div(x) => Some(*x),
            _ => None,
        }
    }
}

#[derive(Clone, Copy, Debug)]
enum Test {
    DivisibleBy(u64),
}

impl FromStr for Test {
    type Err = ();

    fn from_str(input: &str) -> Result<Self, Self::Err> {
        let tokens = input.split(' ').collect::<Vec<_>>();
        match tokens[..] {
            ["divisible", "by", n] => Ok(Test::DivisibleBy(n.parse().unwrap())),
            _ => Err(()),
        }
    }
}

impl Test {
    fn apply(&self, value: u64) -> bool {
        match self {
            Test::DivisibleBy(x) => value % x == 0,
        }
    }

    fn get_factor(&self) -> Option<u64> {
        match self {
            Test::DivisibleBy(x) => Some(*x),
        }
    }
}

fn calculate(monkeys: &[Monkey]) -> u64 {
    let monkeys = &mut monkeys.to_owned();
    monkeys.sort_by(|a, b| b.inspects.cmp(&a.inspects));
    let pair: Vec<u64> = monkeys.iter().take(2).map(|m| m.inspects as u64).collect();
    pair.iter().product()
}

/// Find a sensible modulus
fn find_mod(monkeys: &[Monkey]) -> u64 {
    monkeys
        .iter()
        .flat_map(|m| vec![m.operation.get_factor(), m.test.get_factor()])
        .flatten()
        .product()
}

fn parse(input: &str) -> Vec<Monkey> {
    input
        .trim()
        .split("\n\n")
        .map(|block| {
            let mut iter = block.lines();
            iter.next();
            Monkey {
                items: iter
                    .next()
                    .unwrap()
                    .rsplit_once(':')
                    .unwrap()
                    .1
                    .split(',')
                    .map(|x| x.trim().parse().unwrap())
                    .collect(),
                operation: iter
                    .next()
                    .unwrap()
                    .rsplit_once(':')
                    .unwrap()
                    .1
                    .trim()
                    .parse()
                    .unwrap(),
                test: iter
                    .next()
                    .unwrap()
                    .rsplit_once(':')
                    .unwrap()
                    .1
                    .trim()
                    .parse()
                    .unwrap(),
                pass: iter
                    .next()
                    .unwrap()
                    .split(' ')
                    .last()
                    .unwrap()
                    .parse()
                    .unwrap(),
                fail: iter
                    .next()
                    .unwrap()
                    .split(' ')
                    .last()
                    .unwrap()
                    .parse()
                    .unwrap(),
                inspects: 0,
            }
        })
        .collect()
}

fn pretty_print(monkeys: Vec<Monkey>) {
    for (i, monkey) in monkeys.iter().enumerate() {
        println!("Monkey {} inspected items {} times", i, monkey.inspects);
    }
}

/// Simulate the monkeys for one round
fn simulate(monkeys: &[Monkey], degrade: bool, m: u64) -> Vec<Monkey> {
    let monkeys: &mut [Monkey] = &mut monkeys.to_owned();

    for i in 0..monkeys.len() {
        let monkey = monkeys[i].clone();
        let items = monkey.items;

        monkeys[i] = Monkey {
            items: VecDeque::new(),
            inspects: monkey.inspects + items.len(),
            ..monkey
        };

        for item in items {
            let mut operations = vec![monkey.operation];
            if degrade {
                operations.push(Operation::Div(3));
            }
            let new_item = operations.iter().fold(item, |acc, op| op.apply(acc, m));

            let j = if monkey.test.apply(new_item) {
                monkey.pass
            } else {
                monkey.fail
            } as usize;
            let target = monkeys.get_mut(j).unwrap();
            target.items.push_back(new_item);
        }
    }

    monkeys.to_vec()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 11);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 11);
        assert_eq!(part_one(&input), Some(10605));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 11);
        assert_eq!(part_two(&input), Some(2713310158));
    }
}
