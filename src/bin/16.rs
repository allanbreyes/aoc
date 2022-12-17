use std::collections::HashMap;

use ndarray::Array2;

use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{alpha1, newline, space1},
    combinator::map,
    multi::{many1, separated_list1},
    number::complete::recognize_float,
    sequence::{preceded, terminated, tuple},
    IResult,
};

const BIG: usize = 100;

pub fn part_one(input: &str) -> Option<i32> {
    let mut cache = Cache::new();
    let cave = parse(input).compress();

    let state = State {
        available: cave.lookup.values().copied().collect(),
        actors: vec![Actor {
            time: 30,
            pos: cave.start,
        }],
    };
    Some(cave.solve(state, &mut cache))
}

pub fn part_two(input: &str) -> Option<i32> {
    let mut cache = Cache::new();
    let cave = parse(input).compress();

    let state = State {
        available: cave.lookup.values().copied().collect(),
        actors: vec![
            Actor {
                time: 26,
                pos: cave.start,
            },
            Actor {
                time: 26,
                pos: cave.start,
            },
        ],
    };
    Some(cave.solve(state, &mut cache))
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
struct Actor {
    time: i32,
    pos: usize,
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
struct Valve {
    rate: usize,
    edges: Vec<usize>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
struct Cave {
    lookup: HashMap<String, usize>,
    valves: Vec<Valve>,
    start: usize,
    dist: Array2<usize>,
}

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
struct State {
    available: Vec<usize>,
    actors: Vec<Actor>,
}

type Cache = HashMap<State, i32>;

impl Cave {
    fn compress(&self) -> Self {
        let mut lookup: HashMap<String, usize> = HashMap::new();
        let mut valves: Vec<Valve> = Vec::new();
        let mut start: usize = usize::MIN;

        let compressed: Vec<usize> = (0..self.valves.len())
            .filter(|i| {
                self.dist[(*i, self.start)] < BIG && self.valves[*i].rate > 0 || (*i == self.start)
            })
            .collect();

        let mut dist: Array2<usize> = Array2::from_elem((compressed.len(), compressed.len()), BIG);

        for (j, i) in compressed.iter().enumerate() {
            if *i == self.start {
                start = j;
            }
            lookup.insert(self.rlookup(*i).clone(), j);
        }

        for i in compressed.iter() {
            valves.push(Valve {
                rate: self.valves[*i].rate,
                edges: self.valves[*i]
                    .edges
                    .iter()
                    .filter(|e| compressed.contains(e))
                    .map(|e| lookup[&self.rlookup(*e)])
                    .collect(),
            });
        }

        for j in 0..compressed.len() {
            for k in 0..compressed.len() {
                dist[(j, k)] = self.dist[(compressed[j], compressed[k])] + 1;
            }
        }

        Cave {
            lookup,
            valves,
            start,
            dist,
        }
    }

    fn rlookup(&self, i: usize) -> String {
        self.lookup
            .iter()
            .find(|(_, v)| **v == i)
            .unwrap()
            .0
            .clone()
    }

    fn solve(&self, state: State, cache: &mut Cache) -> i32 {
        if let Some(value) = cache.get(&state) {
            return *value;
        }
        if state.actors.is_empty() {
            return 0;
        }

        let mut best = 0;
        let me = &state.actors[0];

        for i in state.available.iter() {
            let available: Vec<usize> = state
                .available
                .iter()
                .filter(|j| *j != i)
                .copied()
                .collect();

            let time = me.time - self.dist[(me.pos, *i)] as i32;
            if time < 0 {
                continue;
            }

            let mut actors = state.actors.clone();
            actors[0] = Actor { time, pos: *i };
            let trial = State { available, actors };

            best = best.max(self.solve(trial, cache) + (time * self.valves[*i].rate as i32));
        }

        if state.actors.len() > 1 {
            let trial = State {
                available: state.available.clone(),
                actors: state.actors[1..].to_vec(),
            };

            best = best.max(self.solve(trial, cache));
        }

        cache.insert(state, best);
        best
    }
}

fn calc_distances(valves: Vec<Valve>) -> Array2<usize> {
    // Initialize distances with large values
    let mut dist = Array2::from_elem((valves.len(), valves.len()), BIG);

    // Set distances for self and edges
    for (i, valve) in valves.iter().enumerate() {
        dist[(i, i)] = 0;
        for edge in &valve.edges {
            dist[(i, *edge)] = 1;
        }
    }

    // Floyd-Warshall
    // See: https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm
    for i in 0..valves.len() {
        for j in 0..valves.len() {
            for k in 0..valves.len() {
                dist[(j, k)] = dist[(j, k)].min(dist[(j, i)] + dist[(i, k)]);
            }
        }
    }

    dist
}

type ParseResult<'a> = IResult<&'a str, Vec<(&'a str, &'a str, Vec<&'a str>)>>;
fn parse(input: &str) -> Cave {
    let result: ParseResult = many1(terminated(
        map(
            tuple((
                preceded(tag("Valve "), terminated(alpha1, space1)),
                preceded(tag("has flow rate="), terminated(recognize_float, tag(";"))),
                preceded(
                    alt((
                        tag(" tunnels lead to valves "),
                        tag(" tunnel leads to valve "),
                    )),
                    separated_list1(tag(", "), alpha1),
                ),
            )),
            |(name, rate, edges)| (name, rate, edges),
        ),
        newline,
    ))(input);

    let (_, values) = result.unwrap();
    let mut lookup: HashMap<String, usize> = HashMap::new();
    let mut valves: Vec<Valve> = Vec::new();
    let mut start: usize = usize::MIN;

    for (i, (name, _, _)) in values.iter().enumerate() {
        if *name == "AA" {
            start = i;
        }
        lookup.insert(name.to_string(), i);
    }

    for (_, rate, edges) in values {
        valves.push(Valve {
            rate: rate.parse().unwrap(),
            edges: edges.iter().map(|name| lookup[&name.to_string()]).collect(),
        })
    }

    let dist = calc_distances(valves.clone());

    Cave {
        lookup,
        valves,
        start,
        dist,
    }
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 16);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 16);
        assert_eq!(part_one(&input), Some(1651));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 16);
        assert_eq!(part_two(&input), Some(1707));
    }

    #[test]
    fn test_compress() {
        let input = advent_of_code::read_file("examples", 16);
        let cave = parse(&input).compress();
        let expected: Array2<usize> = Array2::from_shape_vec(
            (7, 7),
            vec![
                1, 2, 3, 2, 3, 6, 3, // 1
                2, 1, 2, 3, 4, 7, 4, // 2
                3, 2, 1, 2, 3, 6, 5, // 3
                2, 3, 2, 1, 2, 5, 4, // 4
                3, 4, 3, 2, 1, 4, 5, // 5
                6, 7, 6, 5, 4, 1, 8, // 6
                3, 4, 5, 4, 5, 8, 1, // 7
            ],
        )
        .unwrap();
        assert_eq!(cave.dist, expected);

        let twice = cave.compress();
        assert_eq!(cave.valves, twice.valves);
    }
}
