pub fn part_one(input: &str) -> Option<i32> {
    get_calories(input, 1)
}

pub fn part_two(input: &str) -> Option<i32> {
    get_calories(input, 3)
}

fn get_calories(input: &str, n: usize) -> Option<i32> {
    // Parse the input and sum each group's calories
    let mut calories: Vec<i32> = input.split("\n\n").map(|elf| {
        elf.split('\n')
        .map(|line| line.parse::<i32>().unwrap_or(0))
        .reduce(|a, b| a + b)
        .unwrap_or(0)
    })
    .collect();

    // Sort and return the sum of the top N
    calories.sort();
    calories
    .iter()
    .rev()
    .take(n)
    .fold(Some(0), |acc, &x| {
        Some(acc.unwrap_or(0) + x)
    })
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 1);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 1);
        assert_eq!(part_one(&input), Some(24000));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 1);
        assert_eq!(part_two(&input), Some(45000));
    }
}
