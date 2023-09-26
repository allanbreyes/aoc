use std::cell::Cell;

pub fn part_one(input: &str) -> Option<i32> {
    let instructions = parse(input);
    let (signal, _) = simulate(&instructions);
    let fingerprint = fingerprint(signal);
    Some(fingerprint.iter().sum())
}

pub fn part_two(input: &str) -> Option<String> {
    let instructions = parse(input);
    let (signal, _) = simulate(&instructions);
    Some(draw(signal))
}

struct Register {
    value: Cell<i32>,
}

impl Register {
    fn new() -> Register {
        Register {
            value: Cell::new(1),
        }
    }

    fn get(&self) -> i32 {
        self.value.get()
    }

    fn set(&self, value: i32) {
        self.value.set(value);
    }
}

#[derive(Debug)]
enum Instruction {
    Noop,
    AddX(i32),
    Wait,
}

impl Instruction {
    fn apply(&self, register: &Register) {
        if let Instruction::AddX(x) = self {
            register.set(register.get() + x);
        }
    }

    fn delay(&self) -> usize {
        match self {
            Instruction::AddX(_) => 1,
            _ => 0,
        }
    }
}

fn parse(input: &str) -> Vec<Instruction> {
    input
        .trim()
        .lines()
        .map(|line| {
            let parts = line.split_whitespace().collect::<Vec<_>>();
            match parts[..] {
                ["noop"] => Instruction::Noop,
                ["addx", x] => Instruction::AddX(x.parse().unwrap()),
                _ => panic!("invalid instruction: {}", line),
            }
        })
        .collect()
}

fn draw(signal: Vec<i32>) -> String {
    let (w, h) = (40, 6);
    let mut rows = vec![vec!['?'; w]; h];
    let mut buffer = String::new();
    for (i, &x) in signal[1..].iter().enumerate() {
        let row = i / w;
        let col = i % w;
        rows[row][col] = if (x - col as i32).abs() < 2 { '#' } else { '.' };
    }

    for row in rows {
        buffer.push_str(row.iter().collect::<String>().as_str());
        buffer.push('\n');
    }

    buffer
}
fn fingerprint(signal: Vec<i32>) -> Vec<i32> {
    // Get the signal strength at every 20th cycle
    signal
        .iter()
        .enumerate()
        .filter(|&(i, _)| (20..240).contains(&i) && (i - 20) % 40 == 0)
        .map(|(i, &x)| x * i as i32)
        .collect()
}

fn simulate(instructions: &[Instruction]) -> (Vec<i32>, Vec<&Instruction>) {
    let register = Register::new();
    let mut history: Vec<&Instruction> = vec![&Instruction::Wait];
    let mut signal: Vec<i32> = vec![register.get()];

    for instruction in instructions {
        for _ in 0..instruction.delay() {
            signal.push(register.get());
            history.push(&Instruction::Wait);
        }
        signal.push(register.get());
        history.push(instruction);
        instruction.apply(&register);
    }

    (signal, history)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 10);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 10);
        assert_eq!(part_one(&input), Some(13140));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 10);
        assert_eq!(
            part_two(&input),
            Some(
                "##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######.....
"
                .to_string()
            )
        );
    }

    #[test]
    fn test_simulate() {
        let input = "noop\naddx 3\naddx -5\n";
        let instructions = parse(input);
        let (signal, _) = simulate(&instructions);
        assert_eq!(signal, vec![1, 1, 1, 1, 4, 4]);
    }

    #[test]
    fn test_fingerprint() {
        let input = advent_of_code::read_file("examples", 10);
        let instructions = parse(&input);
        let (signal, history) = simulate(&instructions);
        for (i, &x) in signal.iter().enumerate() {
            if i % 20 == 0 {
                println!("{}:\t{}\t{:?}\t{}", i, x, history[i], x * i as i32);
            } else {
                println!("{}:\t{}\t{:?}", i, x, history[i]);
            }
        }
        let fingerprint = fingerprint(signal);
        assert_eq!(fingerprint, vec![420, 1140, 1800, 2940, 2880, 3960]);
    }
}
