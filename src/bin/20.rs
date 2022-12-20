pub fn part_one(input: &str) -> Option<i32> {
    let values = &parse(input)[..];
    let mut pointers: Vec<usize> = (0..values.len()).collect();
    mix(&values, &mut pointers);
    Some(calculate(values, pointers))
}

pub fn part_two(input: &str) -> Option<u32> {
    None
}

fn mix(values: &[i32], pointers: &mut Vec<usize>) {
    let divisor = values.len() as i32 - 1; // One less, before swapping
    for (i, &value) in values.iter().enumerate() {
        let index: i32 = pointers
            .iter()
            .position(|&p| p == i)
            .unwrap()
            .try_into()
            .unwrap();

        pointers.remove(index as usize);
        pointers.insert(
            // https://doc.rust-lang.org/std/primitive.i32.html#method.rem_euclid
            (index + value).rem_euclid(divisor) as usize,
            i,
        )
    }
}

fn calculate(values: &[i32], pointers: Vec<usize>) -> i32 {
    let zero_ptr = values.iter().position(|&v| v == 0).unwrap();
    let offset = pointers.iter().position(|&p| p == zero_ptr).unwrap();
    [1000, 2000, 3000]
        .iter()
        .map(|i| values[pointers[(offset + i) % values.len()]])
        .sum()
}

fn parse(input: &str) -> Vec<i32> {
    input.lines().map(|line| line.parse().unwrap()).collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 20);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 20);
        assert_eq!(part_one(&input), Some(3));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 20);
        assert_eq!(part_two(&input), None);
    }
}
