use std::fmt;

pub fn part_one(input: &str) -> Option<u32> {
    score_part_one(input)
}

pub fn part_two(input: &str) -> Option<u32> {
    score_part_two(input)
}

#[derive(Debug)]
enum Play {
    Rock,
    Paper,
    Scissors,
}

impl Play {
    fn value(&self) -> u32 {
        match *self {
            Play::Rock => 1,
            Play::Paper => 2,
            Play::Scissors => 3,
        }
    }
}

impl fmt::Display for Play {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Play::Rock => write!(f, "RCK"),
            Play::Paper => write!(f, "PPR"),
            Play::Scissors => write!(f, "SCR"),
        }
    }
}

enum Result {
    Win,
    Draw,
    Loss,
}

impl Result {
    fn value(&self) -> u32 {
        match *self {
            Result::Win => 6,
            Result::Draw => 3,
            Result::Loss => 0,
        }
    }
}

fn score_part_one(input: &str) -> Option<u32> {
    input.trim().split('\n').map(|line| {
        let plays = line.split(' ').map(|word| {
            match word {
                "A" | "X" => Play::Rock,
                "B" | "Y" => Play::Paper,
                "C" | "Z" => Play::Scissors,
                _ => panic!("Invalid input"),
            }
        }).collect::<Vec<Play>>();

        if plays.len() != 2 {
            panic!("Invalid input");
        }
        let opponent = &plays[0];
        let player = &plays[1];
        
        score(opponent, player)
    })
    .reduce(|a, b| a + b)
}

fn score_part_two(input: &str) -> Option<u32> {
    input.trim().split('\n').map(|line| {
        let parts: Vec<&str> = line.split(' ').collect();
        if parts.len() != 2 {
            panic!("Invalid input");
        }

        let opponent = match parts[0] {
            "A" => Play::Rock,
            "B" => Play::Paper,
            "C" => Play::Scissors,
            _ => panic!("Invalid input"),
        };

        let result = match parts[1] {
            "X" => Result::Loss,
            "Y" => Result::Draw,
            "Z" => Result::Win,
            _ => panic!("Invalid input"),
        };

        let player = match result {
            Result::Win => match opponent {
                Play::Rock => Play::Paper,
                Play::Paper => Play::Scissors,
                Play::Scissors => Play::Rock,
            },
            Result::Draw => match opponent {
                Play::Rock => Play::Rock,
                Play::Paper => Play::Paper,
                Play::Scissors => Play::Scissors,
            },
            Result::Loss => match opponent {
                Play::Rock => Play::Scissors,
                Play::Paper => Play::Rock,
                Play::Scissors => Play::Paper,
            },
        };

        score(&opponent, &player)
    })
    .reduce(|a, b| a + b)
}

fn score(opponent: &Play, player: &Play) -> u32 {
    let result = if opponent.value() == player.value() {
        Result::Draw
    } else {
        match (player, opponent) {
            (Play::Rock, Play::Paper) => Result::Loss,
            (Play::Paper, Play::Scissors) => Result::Loss,
            (Play::Scissors, Play::Rock) => Result::Loss,
            (Play::Rock, Play::Scissors) => Result::Win,
            (Play::Paper, Play::Rock) => Result::Win,
            (Play::Scissors, Play::Paper) => Result::Win,
            _ => panic!("Invalid input"),
        }
    };
    result.value() + player.value()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 2);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 2);
        assert_eq!(part_one(&input), Some(15));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 2);
        assert_eq!(part_two(&input), Some(12));
    }

    #[test]
    fn test_score() {
        assert_eq!(score(&Play::Rock, &Play::Rock), 4);
        assert_eq!(score(&Play::Rock, &Play::Paper), 8);
        assert_eq!(score(&Play::Rock, &Play::Scissors), 3);
        assert_eq!(score(&Play::Paper, &Play::Rock), 1);
        assert_eq!(score(&Play::Paper, &Play::Paper), 5);
        assert_eq!(score(&Play::Paper, &Play::Scissors), 9);
        assert_eq!(score(&Play::Scissors, &Play::Rock), 7);
        assert_eq!(score(&Play::Scissors, &Play::Paper), 2);
        assert_eq!(score(&Play::Scissors, &Play::Scissors), 6);
    }
}
