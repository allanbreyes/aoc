use std::collections::HashSet;

pub fn part_one(input: &str) -> Option<u32> {
    parse_input_one(input).iter().map(|(left, right)| {
        let common = find_common(left, right);
        if common.len() != 1 {
            println!("{} + {}", left, right);
            for c in common {
                print!("{}", c);
            }
            panic!("found more than one common character");
        }
        let char = common[0];
        get_priority(char)
    })
    .reduce(|a, b| a + b)
}

pub fn part_two(input: &str) -> Option<u32> {
    parse_input_two(input).iter().map(|group| {
        let common = group.iter().fold(HashSet::new(), |acc, s| {
            if acc.is_empty() {
                s.chars().collect()
            } else {
                acc.intersection(&s.chars().collect()).cloned().collect()
            }
        });
        if common.len() != 1 {
            panic!("found more than one common character");
        }
        get_priority(common.into_iter().next().unwrap())
    })
    .reduce(|a, b| a + b)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 3);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

fn parse_input_one(input: &str) -> Vec<(&str, &str)> {
    input.trim().lines().map(|line| {
        if line.len() % 2 != 0 {
            panic!("Invalid input");
        }

        line.split_at(line.len() / 2)
    })
    .collect()
}

fn parse_input_two(input: &str) -> Vec<Vec<&str>> {
    let mut groups = Vec::new();
    let mut group = Vec::new();

    for (i, line) in input.trim().lines().enumerate() {
        group.push(line);

        if (i + 1) % 3 == 0 {
            groups.push(group);
            group = Vec::new();
        }
    }

    groups
}

fn find_common(a: &str, b: &str) -> Vec<char> {
    let set_a = a.chars().collect::<HashSet<char>>();
    let set_b = b.chars().collect::<HashSet<char>>();
    set_a.intersection(&set_b).cloned().collect()
}

fn get_priority(c: char) -> u32 {
    let i = c as u32;
    if c.is_ascii_lowercase() {
        i - 96
    } else {
        i - 64 + 26
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 3);
        assert_eq!(part_one(&input), Some(157));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 3);
        assert_eq!(part_two(&input), Some(70));
    }

    #[test]
    fn test_get_priority() {
        assert_eq!(get_priority('a'), 1);
        assert_eq!(get_priority('z'), 26);
        assert_eq!(get_priority('A'), 27);
        assert_eq!(get_priority('Z'), 52);
    }
}
