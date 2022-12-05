pub fn part_one(input: &str) -> Option<u32> {
    let binding = parse(&input);
    let contained = binding.iter().filter(|(left, right)| {
        left.contains(right) || right.contains(left)
    });
    Some(contained.count() as u32)
}

pub fn part_two(input: &str) -> Option<u32> {
    let binding = parse(&input);
    let overlapped = binding.iter().filter(|(left, right)| {
        left.overlaps(right)
    });
    Some(overlapped.count() as u32)
}

struct Range {
    lo: u32,
    hi: u32,
}

impl Range {
    fn new(lo: u32, hi: u32) -> Range {
        Range { lo, hi }
    }

    fn from_str(s: &str) -> Range {
        let mut parts = s.split('-');
        let lo = parts.next().unwrap().parse().unwrap();
        let hi = parts.next().unwrap().parse().unwrap();
        Range::new(lo, hi)
    }

    fn contains(&self, other: &Range) -> bool {
        self.lo <= other.lo && other.hi <= self.hi
    }

    fn overlaps(&self, other: &Range) -> bool {
        self.lo <= other.hi && other.lo <= self.hi
    }
}

fn parse_line(line: &str) -> Option<(Range, Range)> {
    let parts: Vec<&str> = line.split(',').collect();
    if parts.len() != 2 {
        return None;
    }

    let a = Range::from_str(parts[0]);
    let b = Range::from_str(parts[1]);
    Some((a, b))
}

fn parse(input: &str) -> Vec<(Range, Range)> {
    input.trim().lines().map(|line| {
        let result = parse_line(line);
        if result.is_some() {
            result.unwrap()
        } else {
            panic!("Invalid input");
        }
    })
    .collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 4);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 4);
        assert_eq!(part_one(&input), Some(2));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 4);
        assert_eq!(part_two(&input), Some(4));
    }
}
