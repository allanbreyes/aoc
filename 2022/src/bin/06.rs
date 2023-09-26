use std::collections::HashSet;

pub fn part_one(input: &str) -> Option<u32> {
    detect(&parse(input), 4)
}

pub fn part_two(input: &str) -> Option<u32> {
    detect(&parse(input), 14)
}

// Detect a series of unique characters of a specified size
fn detect(chars: &[char], size: usize) -> Option<u32> {
    for i in 0..chars.len() - size {
        let j = i + size;
        let set: HashSet<char> = chars[i..j].iter().cloned().collect();
        if set.len() == size {
            return Some(j.try_into().unwrap());
        }
    }
    None
}

fn parse(input: &str) -> Vec<char> {
    let result: Vec<char> = input.chars().collect();
    if result.len() < 4 {
        panic!("Input too short");
    }
    result
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 6);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 6);
        assert_eq!(part_one(&input), Some(7));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 6);
        assert_eq!(part_two(&input), Some(19));
    }
}
