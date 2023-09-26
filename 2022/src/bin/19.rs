use std::fmt::{Debug, Formatter, Result as FmtResult};

use sscanf::sscanf;

pub fn part_one(input: &str) -> Option<Count> {
    let blueprints = parse(input);
    let best: Count = blueprints
        .iter()
        .map(|b| simulate(b, 24) * b.number as Count)
        .sum();
    Some(best)
}

pub fn part_two(input: &str) -> Option<Count> {
    let blueprints = parse(input);
    let product: Count = blueprints.iter().take(3).map(|b| simulate(b, 32)).product();
    Some(product)
}

const ORE: usize = 0;
const CLAY: usize = 1;
const OBSIDIAN: usize = 2;
const GEODE: usize = 3;

type Count = u16;

#[derive(Clone)]
struct Resources(Count, Count, Count, Count);

impl Debug for Resources {
    fn fmt(&self, f: &mut Formatter) -> FmtResult {
        write!(
            f,
            "Resources(ore: {}, clay: {}, obsidian: {}, geode: {})",
            self.get(ORE),
            self.get(CLAY),
            self.get(OBSIDIAN),
            self.get(GEODE),
        )
    }
}

impl Resources {
    fn add(&mut self, i: usize, value: Count) {
        match i {
            0 => self.0 += value,
            1 => self.1 += value,
            2 => self.2 += value,
            3 => self.3 += value,
            _ => panic!("invalid index"),
        }
    }

    fn get(&self, i: usize) -> Count {
        match i {
            0 => self.0,
            1 => self.1,
            2 => self.2,
            3 => self.3,
            _ => panic!("invalid index"),
        }
    }
    fn sub(&mut self, i: usize, value: Count) {
        match i {
            0 => self.0 -= value,
            1 => self.1 -= value,
            2 => self.2 -= value,
            3 => self.3 -= value,
            _ => panic!("invalid index"),
        }
    }
}

#[derive(Debug)]
struct Blueprint {
    number: u16,
    costs: [Resources; 4],
}

#[derive(Debug)]
struct State {
    resources: Resources,
    robots: [Count; 4],
    time: u16,
}

fn recurse(
    blueprint: &Blueprint,
    state: State,
    best: &mut Count,
    robot_limits: [Count; 4],
    time_limit: u16,
) {
    let mut recursed = false;
    for i in [ORE, CLAY, OBSIDIAN, GEODE].iter() {
        let cost = &blueprint.costs[*i];
        if state.robots[*i] >= robot_limits[*i] {
            continue;
        }
        let delay = [ORE, CLAY, OBSIDIAN]
            .iter()
            .map(|j| {
                let r = *j;
                if cost.get(r) <= state.resources.get(r) {
                    0
                } else if state.robots[r] == 0 {
                    time_limit as Count + 1
                } else {
                    (cost.get(r) - state.resources.get(r) + state.robots[r] - 1) / state.robots[r]
                }
            })
            .max()
            .unwrap();

        let finished = state.time + delay + 1;
        if finished >= time_limit {
            continue;
        }

        let mut resources = state.resources.clone();
        let mut robots = state.robots;

        for j in [ORE, CLAY, OBSIDIAN, GEODE].iter() {
            resources.add(*j, state.robots[*j] * (delay + 1));
            resources.sub(*j, cost.get(*j));
            robots[*j] += Count::from(*j == *i);
        }

        let remainder = time_limit - finished;
        let heuristic = resources.get(GEODE) + remainder * robots[GEODE] + remainder.pow(2) / 2;
        if heuristic < *best {
            continue;
        }

        recurse(
            blueprint,
            State {
                resources,
                robots,
                time: finished,
            },
            best,
            robot_limits,
            time_limit,
        );
        recursed = true;
    }
    if !recursed {
        let produced = state.robots[GEODE] * (time_limit - state.time);
        *best = *best.max(&mut (state.resources.get(GEODE) + produced));
    }
}

fn simulate(blueprint: &Blueprint, time_limit: u16) -> Count {
    let mut best = 0;
    let robot_limits: [Count; 4] = [ORE, CLAY, OBSIDIAN, GEODE]
        .iter()
        .map(|i| match i {
            3 => Count::MAX,
            _ => blueprint.costs.iter().map(|c| c.get(*i)).max().unwrap(),
        })
        .collect::<Vec<Count>>()
        .try_into()
        .unwrap();
    let state = State {
        resources: Resources(0, 0, 0, 0),
        robots: [1, 0, 0, 0],
        time: 0,
    };
    recurse(blueprint, state, &mut best, robot_limits, time_limit);
    best
}

fn parse(input: &str) -> Vec<Blueprint> {
    input.trim().lines().map(|line| {
        let (
            number,
            ore_ore,
            clay_ore,
            obs_ore,
            obs_clay,
            geo_ore,
            geo_obs
        ) = sscanf!(
            line,
            "Blueprint {}: Each ore robot costs {} ore. Each clay robot costs {} ore. Each obsidian robot costs {} ore and {} clay. Each geode robot costs {} ore and {} obsidian.",
            u16, Count, Count, Count, Count, Count, Count
        ).expect("parsing failed");
            let ore = Resources(ore_ore, 0, 0, 0);
            let clay = Resources(clay_ore, 0, 0, 0);
            let obsidian = Resources(obs_ore, obs_clay, 0, 0);
            let geode = Resources(geo_ore, 0, geo_obs, 0);
            let costs = [ore, clay, obsidian, geode];
            Blueprint { number, costs }
    }).collect()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 19);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 19);
        assert_eq!(part_one(&input), Some(33));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 19);
        assert_eq!(part_two(&input), Some(3472));
    }
}
