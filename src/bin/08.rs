use std::fmt;

pub fn part_one(input: &str) -> Option<u32> {
    let mut forest = parse(input);
    for (i, j) in get_corners(&forest) {
        forest[i][j].visible = true;
    }
    for (position, direction) in get_vectors(&forest) {
        survey(&mut forest, position, direction);
    }
    if forest.len() < 10 {
        pretty_print(&forest);
    }
    Some(count_visible(&forest))
}

pub fn part_two(input: &str) -> Option<u32> {
    let mut forest = parse(input);
    let (num_rows, num_cols) = get_shape(&forest);
    for i in 0..num_rows {
        for j in 0..num_cols {
            forest[i][j].score = score(&forest, (i, j));
        }
    }
    forest.into_iter().flatten().max_by_key(|tree| tree.score).map(|tree| tree.score)
}

#[derive(Debug)]
struct Tree {
    height: u32,
    visible: bool,
    score: u32,
}

impl fmt::Display for Tree {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        if self.visible {
            write!(f, "^")
        } else {
            write!(f, ".")
        }
    }
}

type Forest = Vec<Vec<Tree>>;
type Position = (usize, usize);
type Direction = (isize, isize);

const UP: Direction = (-1, 0);
const RIGHT: Direction = (0, 1);
const DOWN: Direction = (1, 0);
const LEFT: Direction = (0, -1);

fn count_visible(forest: &Forest) -> u32 {
    forest.iter().map(|row| {
        row.iter().filter(|tree| tree.visible).count() as u32
    }).sum()
}

fn get_corners(forest: &Forest) -> Vec<Position> {
    let (num_rows, num_cols) = get_shape(forest);
    let mut corners = Vec::new();
    if num_rows > 0 && num_cols > 0 {
        corners.push((0, 0));
        corners.push((0, num_cols-1));
        corners.push((num_rows-1, 0));
        corners.push((num_rows-1, num_cols-1));
    }
    corners
}

fn get_shape(forest: &Forest) -> (usize, usize) {
    if forest.is_empty() {
        return (0, 0);
    } 
    let num_rows = forest.len();
    let num_cols = if !forest[0].is_empty() {
        forest[0].len()
    } else {
        0
    };
    (num_rows, num_cols)
}

fn get_vectors(forest: &Forest) -> Vec<(Position, Direction)> {
    let (num_rows, num_cols) = get_shape(forest);
    let mut vectors = Vec::new();

    // Add edges in order of top, right, bottom, left
    vectors.extend((1..num_cols-1).map(|j| ((0, j), DOWN)));
    vectors.extend((1..num_rows-1).map(|i| ((i, num_cols-1), LEFT)));
    vectors.extend((1..num_cols-1).rev().map(|j| ((num_rows-1, j), UP)));
    vectors.extend((1..num_rows-1).rev().map(|i| ((i, 0), RIGHT)));
    vectors
}

fn score(forest: &Forest, position: Position) -> u32 {
    let (num_rows, num_cols) = get_shape(forest);
    let (mut i, mut j) = position;
    let height = forest[i][j].height;
    let mut score = 1;

    for (di, dj) in &[UP, RIGHT, DOWN, LEFT] {
        (i, j) = position;
        let mut count = 0;

        i = (i as isize + di) as usize;
        j = (j as isize + dj) as usize;

        while i < num_rows && j < num_cols {
            count += 1;

            if forest[i][j].height >= height {
                break;
            }

            i = (i as isize + di) as usize;
            j = (j as isize + dj) as usize;
        }
        score *= count;
    }

    score
}

fn survey(forest: &mut Forest, position: Position, direction: Direction) -> &mut Forest {
    let (num_rows, num_cols) = get_shape(forest);
    let (mut i, mut j) = position;
    let (di, dj) = direction;
    let mut max_height = forest[i][j].height;

    // Mark the first tree as visible and move to the next tree
    forest[i][j].visible = true;
    i = (i as isize + di) as usize;
    j = (j as isize + dj) as usize;

    while i < num_rows && j < num_cols && i > 0 && j > 0 {
        // Mark trees as visible if they are taller than the tallest seen tree
        if forest[i][j].height > max_height {
            max_height = forest[i][j].height;
            forest[i][j].visible = true;
        }

        i = (i as isize + di) as usize;
        j = (j as isize + dj) as usize;
    }
    forest
}

fn parse(input: &str) -> Forest {
    let mut trees: Forest = Vec::new();
    for line in input.lines() {
        let mut row = Vec::new();
        for char in line.chars() {
            let tree = Tree {
                height: char.to_digit(10).unwrap(),
                score: 0,
                visible: false,
            };
            row.push(tree);
        }
        trees.push(row);
    }
    trees
}

fn pretty_print(forest: &Forest) {
    for row in forest {
        for tree in row {
            print!("{}", tree);
        }
        println!();
    }
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 8);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 8);
        assert_eq!(part_one(&input), Some(21));

        let small = include_str!("../examples/08-small.txt");
        assert_eq!(part_one(small), Some(45));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 8);
        assert_eq!(part_two(&input), Some(8));
    }
}
