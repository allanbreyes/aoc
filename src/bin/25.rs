pub fn part_one(input: &str) -> Option<String> {
    let sum: i64 = parse(input).iter().cloned().map(from_snafu).sum();
    Some(to_snafu(sum))
}

pub fn part_two(_input: &str) -> Option<String> {
    Some("fin".to_string())
}

fn from_snafu(input: &str) -> i64 {
    input
        .trim()
        .chars()
        .rev()
        .enumerate()
        .map(|(i, c)| match c {
            '2' => 2,
            '1' => 1,
            '0' => 0,
            '-' => -1,
            '=' => -2,
            _ => panic!("invalid digit"),
        } * 5_i64.pow(i as u32))
        .sum()
}

fn to_snafu(decimal: i64) -> String {
    let mut left = decimal;
    let mut digits = Vec::new();
    while left > 0 {
        let rem = (left + 2) % 5 - 2;
        left = (left + 2) / 5;
        digits.insert(
            0,
            match rem {
                -2 => '=',
                -1 => '-',
                0 => '0',
                1 => '1',
                2 => '2',
                _ => panic!("invalid condition"),
            },
        )
    }
    digits.iter().collect()
}

fn parse(input: &str) -> Vec<&str> {
    input.trim().split('\n').collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 25);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 25);
        assert_eq!(part_one(&input), Some("2=-1=0".to_string()));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 25);
        assert_eq!(part_two(&input), Some("fin".to_string()));
    }

    #[test]
    fn test_from_snafu() {
        assert_eq!(from_snafu("1=-0-2"), 1747);
        assert_eq!(from_snafu("12111"), 906);
        assert_eq!(from_snafu("2=0="), 198);
        assert_eq!(from_snafu("21"), 11);
        assert_eq!(from_snafu("2=01"), 201);
        assert_eq!(from_snafu("111"), 31);
        assert_eq!(from_snafu("20012"), 1257);
        assert_eq!(from_snafu("112"), 32);
        assert_eq!(from_snafu("1=-1="), 353);
        assert_eq!(from_snafu("1-12"), 107);
        assert_eq!(from_snafu("12"), 7);
        assert_eq!(from_snafu("1="), 3);
        assert_eq!(from_snafu("122"), 37);
    }
}
