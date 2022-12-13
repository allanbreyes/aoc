use std::collections::HashMap;

const THRESHOLD: u32 = 100_000;
const AVAILABLE: u32 = 70_000_000;
const REQ_SPACE: u32 = 30_000_000;

pub fn part_one(input: &str) -> Option<u32> {
    let sizes = get_sizes(input);
    let sum = sizes.values().filter(|&size| *size < THRESHOLD).sum();
    Some(sum)
}

pub fn part_two(input: &str) -> Option<u32> {
    let sizes = get_sizes(input);
    let target = REQ_SPACE - (AVAILABLE - sizes.get("/").unwrap());

    let mut sizes: Vec<u32> = sizes.values().copied().collect();
    sizes.sort();
    for size in sizes.iter() {
        if size > &target {
            return Some(*size);
        }
    }
    None
}

fn get_sizes(input: &str) -> HashMap<String, u32> {
    let mut files: HashMap<String, u32> = HashMap::new();
    let mut folders: Vec<String> = Vec::new();
    let mut pwd: Vec<&str> = Vec::new();
    let mut sizes: HashMap<String, u32> = HashMap::new();

    // Parse the input
    for line in input.lines() {
        let parts: Vec<&str> = line.split_whitespace().collect();
        match parts[0] {
            // Handle commands
            "$" => {
                match parts[1..] {
                    ["cd", "/"] => pwd.clear(), // Go back to root
                    ["cd", ".."] => {
                        let _ = pwd.pop();
                    } // Go back by one
                    ["cd", folder] => pwd.push(folder), // Go into a folder
                    ["ls"] => {}                // No-op; handle output later
                    _ => panic!("undefined behavior"),
                }
            }

            // Handle output
            _ => {
                if parts.len() != 2 {
                    panic!("unparseable output");
                }

                let mut path = pwd.clone();

                match parts[..] {
                    ["dir", directory] => {
                        path.push(directory);
                        folders.push(path.join("/"));
                    }

                    [size, file] => {
                        path.push(file);
                        files.insert(path.join("/"), size.parse().unwrap());
                    }

                    _ => panic!("undefined behavior"),
                }
            }
        }
    }

    // Calculate the sizes of the folders
    for directory in folders.iter() {
        let mut subtotal = 0;
        for (file, size) in files.iter() {
            if file.starts_with(directory) {
                subtotal += size;
            }
        }
        sizes.insert(directory.clone(), subtotal);
    }

    // Calculate the total size of the root folder
    let total: u32 = files.values().sum();
    sizes.insert(String::from("/"), total);

    sizes
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 7);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 7);
        assert_eq!(part_one(&input), Some(95437));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 7);
        assert_eq!(part_two(&input), Some(24933642));
    }
}
