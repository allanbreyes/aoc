use pathfinding::prelude::dijkstra;

pub fn part_one(input: &str) -> Option<usize> {
    let (grid, start) = parse(input);
    let result = dijkstra(&start, |node| successors(node, &grid), |node| success(node));
    let (_, cost) = result.unwrap();
    Some(cost)
}

pub fn part_two(input: &str) -> Option<u32> {
    let (grid, _) = parse(input);
    let starts: Vec<Node> = grid
        .iter()
        .flatten()
        .filter(|node| match node {
            Node::Start(_, _) => true,
            Node::Generic(_, _, h) => *h == 0,
            _ => false,
        })
        .cloned()
        .collect();
    // NOTE: this isn't cached at all, so it's super slow
    let result = starts
        .iter()
        .map(|start| {
            let result = dijkstra(&start.clone(), |node| successors(node, &grid), |node| success(node));
            match result {
                Some((_, cost)) => Some(cost),
                None => None,
            }
        })
        .filter(|cost| cost.is_some())
        .map(|cost| cost.unwrap())
        .min();
    Some(result.unwrap() as u32)
}

const SUMMIT: u32 = 25;

type Grid = Vec<Vec<Node>>;

#[derive(Clone, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
enum Node {
    Start(i32, i32),
    End(i32, i32, u32),
    Generic(i32, i32, u32),
}

impl Node {
    fn coords(&self) -> (i32, i32) {
        match self {
            Node::Start(i, j) => (*i, *j),
            Node::End(i, j, _) => (*i, *j),
            Node::Generic(i, j, _) => (*i, *j),
        }
    }
}

fn parse(input: &str) -> (Grid, Node) {
    let mut start = Node::Start(0, 0);

    let grid = input
        .trim()
        .lines()
        .enumerate()
        .map(|(i, line)| {
            line.chars().enumerate().map(|(j, c)| {
                match c {
                    'S' => {
                        start = Node::Start(i as i32, j as i32);
                        start.clone()
                    },
                    'E' => Node::End(i as i32, j as i32, SUMMIT),
                    _ => Node::Generic(i as i32, j as i32, c as u32 - 'a' as u32),
                }
            }).collect()
        })
        .collect();
    (grid, start)
}

fn shape(grid: &Grid) -> (usize, usize) {
    (grid.len(), grid[0].len())
}

fn success(node: &Node) -> bool {
    match node {
        Node::End(_, _, _) => true,
        _ => false,
    }
}

fn successors(node: &Node, grid: &Grid) -> Vec<(Node, usize)> {
    let mut result = Vec::new();
    let (rows, cols) = shape(grid);
    let (i, j) = node.coords() as (i32, i32);
    let cardinals  = vec![(i - 1, j), (i + 1, j), (i, j - 1), (i, j + 1)];
    let neighbors: Vec<(i32, i32)> = cardinals
        .iter()
        .filter(|(i, j)| *i >= 0 && *i < rows as i32 && *j >= 0 && *j < cols as i32)
        .cloned()
        .collect();
    match node {
        Node::Start(_, _) => {
            result = neighbors
                .iter()
                .map(|(i, j)| {
                    let other = &grid[*i as usize][*j as usize];
                    (other.clone(), 1)
                })
                .collect();
        },
        Node::End(_, _, _) => {},
        Node::Generic(_, _, h) => {
            result = neighbors
                .iter()
                .map(|(i, j)| {
                    let other = &grid[*i as usize][*j as usize];
                    other.clone()
                })
                .filter(|other| match other {
                    Node::Generic(_, _, other_h) => *h as i32 - *other_h as i32 >= -1,
                    Node::End(_, _, _) => *h >= SUMMIT,
                    _ => false,
                })
                .map(|other| (other, 1))
                .collect()
        },
    }
    result
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 12);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 12);
        assert_eq!(part_one(&input), Some(31));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 12);
        assert_eq!(part_two(&input), Some(29));
    }
}
