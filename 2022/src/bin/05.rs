use std::fmt;

pub fn part_one(input: &str) -> Option<String> {
    let (mut stacks, moves) = parse(input);
    apply(&moves, &mut stacks, true);
    Some(pluck(&mut stacks))
}

pub fn part_two(input: &str) -> Option<String> {
    let (mut stacks, moves) = parse(input);
    apply(&moves, &mut stacks, false);
    Some(pluck(&mut stacks))
}

#[derive(Debug)]
struct Move {
    count: usize,
    from: u32,
    to: u32,
}

impl fmt::Display for Move {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{} --{}--> {}", self.from, self.count, self.to)
    }
}

// Apply series of moves to the stacks of crates
fn apply(moves: &[Move], stacks: &mut [Vec<char>], reverse: bool) {
    for m in moves {
        let from = &mut stacks[m.from as usize];
        let crates = from.split_off(from.len() - m.count);
        if reverse {
            stacks[m.to as usize].extend(crates.iter().rev());
        } else {
            stacks[m.to as usize].extend(crates);
        }
    }
}

// Grab the top values from the stacks
fn pluck(stacks: &mut [Vec<char>]) -> String {
    stacks
        .iter()
        .map(|s| s.last().copied())
        .map(|c| c.unwrap())
        .collect()
}

fn parse(input: &str) -> (Vec<Vec<char>>, Vec<Move>) {
    let mut stacks: Vec<Vec<char>> = Vec::new();
    let mut moves: Vec<Move> = Vec::new();

    let (levels_str, moves_str) = input.split_once("\n\n").unwrap();

    // Parse levels
    let mut levels = levels_str.lines().rev();
    let headers = levels
        .next()
        .unwrap()
        .split_whitespace()
        .map(|n| n.parse::<u32>().expect("could not parse level number") - 1)
        .collect::<Vec<u32>>();

    headers.iter().for_each(|_| {
        stacks.push(Vec::new());
    });

    for level in levels {
        level
            .chars()
            .skip(1)
            .step_by(4)
            .zip(headers.iter())
            .for_each(|(c, h)| {
                if c != ' ' {
                    stacks[*h as usize].push(c);
                }
            });
    }

    // Parse moves: move n from a to b
    for line in moves_str.lines() {
        let mut parts = line.split_whitespace();
        parts.next();
        let count = parts
            .next()
            .unwrap()
            .parse()
            .expect("could not parse move count");
        parts.next();
        let from = parts
            .next()
            .unwrap()
            .parse::<u32>()
            .expect("could not parse move from")
            - 1;
        parts.next();
        let to = parts
            .next()
            .unwrap()
            .parse::<u32>()
            .expect("could not parse move to")
            - 1;
        moves.push(Move { from, to, count });
    }

    (stacks, moves)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 5);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 5);
        assert_eq!(part_one(&input), Some("CMZ".into()));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 5);
        assert_eq!(part_two(&input), Some("MCD".into()));
    }
}
