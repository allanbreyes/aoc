pub fn part_one(input: &str) -> Option<i64> {
    let key = 1;
    let values = &parse(input)[..];
    let mut pointers: Vec<usize> = (0..values.len()).collect();
    mix(values, &mut pointers, 1, key);
    Some(calculate(values, pointers, key))
}

pub fn part_two(input: &str) -> Option<i64> {
    let key = 811589153;
    let values = &parse(input)[..];
    let mut pointers: Vec<usize> = (0..values.len()).collect();
    mix(values, &mut pointers, 10, key);
    Some(calculate(values, pointers, key))
}

fn mix(values: &[i64], pointers: &mut Vec<usize>, times: usize, key: i64) {
    let divisor = values.len() as i64 - 1; // One less, before swapping
    let values: Vec<i64> = values.iter().map(|&v| v * key).collect();
    for _ in 0..times {
        for (i, &value) in values.iter().enumerate() {
            let index: i64 = pointers
                .iter()
                .position(|&p| p == i)
                .unwrap()
                .try_into()
                .unwrap();

            pointers.remove(index as usize);
            pointers.insert(
                // https://doc.rust-lang.org/std/primitive.i64.html#method.rem_euclid
                (index + value).rem_euclid(divisor) as usize,
                i,
            )
        }
    }
}

fn calculate(values: &[i64], pointers: Vec<usize>, key: i64) -> i64 {
    let values: Vec<i64> = values.iter().map(|&v| v * key).collect();
    let zero_ptr = values.iter().position(|&v| v == 0).unwrap();
    let offset = pointers.iter().position(|&p| p == zero_ptr).unwrap();
    [1000, 2000, 3000]
        .iter()
        .map(|i| values[pointers[(offset + i) % values.len()]])
        .sum()
}

fn parse(input: &str) -> Vec<i64> {
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
        assert_eq!(part_two(&input), Some(1623178306));
    }
}
