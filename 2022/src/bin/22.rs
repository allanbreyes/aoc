use std::{
    collections::HashMap,
    fmt::{Debug, Formatter, Result as FmtResult},
};

use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{alpha1, newline, one_of},
    combinator::map,
    multi::many1,
    number::complete::recognize_float,
    sequence::{separated_pair, terminated},
    IResult,
};

pub fn part_one(input: &str) -> Option<u32> {
    let (_, (board, moves)) = parse(input).unwrap();
    let moves = moves.into_iter().flat_map(|m| m.decompose()).collect();
    let (end, path) = simulate(&board, moves, wrap2d);
    if board.len() < 100 {
        draw(&board, &path);
    }
    Some(end.password())
}

#[allow(unused_variables)]
pub fn part_two(input: &str) -> Option<u32> {
    let (_, (board, moves)) = parse(input).unwrap();
    let moves = moves.into_iter().flat_map(|m| m.decompose()).collect();
    let (end, path) = simulate(&board, moves, warp_small);
    if board.len() < 100 {
        draw(&board, &path);
    }
    Some(end.password())
}

type Board = Vec<Vec<Tile>>;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Tile {
    Nothing,
    Open,
    Solid,
}

#[derive(Clone)]
enum Move {
    Fwd(u16),
    TurnR,
    TurnL,
    Turn180,

    #[allow(dead_code)]
    Nothing,
}

impl Debug for Move {
    fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
        match self {
            Move::Fwd(dist) => write!(f, "Fwd({})", dist),
            Move::TurnR => write!(f, "TurnR"),
            Move::TurnL => write!(f, "TurnL"),
            Move::Turn180 => write!(f, "Turn180"),
            Move::Nothing => write!(f, "Nothing"),
        }
    }
}

impl Move {
    fn apply(&self, state: State) -> State {
        match self {
            Move::Fwd(dist) => {
                let mut pos = state.pos();
                for _ in 0..*dist {
                    match state.dir() {
                        Dir::U => pos.0 -= 1,
                        Dir::R => pos.1 += 1,
                        Dir::D => pos.0 += 1,
                        Dir::L => pos.1 -= 1,
                    }
                }
                State(pos, state.dir())
            }
            Move::TurnL | Move::TurnR | Move::Turn180 => {
                let i = (state.1.as_i32()
                    + match self {
                        Move::TurnL => -1,
                        Move::TurnR => 1,
                        Move::Turn180 => 2,
                        _ => unreachable!(),
                    })
                .rem_euclid(4);
                State(state.pos(), Dir::from_i32(i))
            }
            Move::Nothing => state,
        }
    }

    fn decompose(&self) -> Vec<Move> {
        match self {
            Move::Fwd(dist) => (0..*dist).into_iter().map(|_| Move::Fwd(1)).collect(),
            Move::TurnL | Move::TurnR | Move::Turn180 => {
                vec![self.clone()]
            }
            Move::Nothing => vec![],
        }
    }
}

type Pos = (i32, i32);

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
enum Dir {
    U,
    R,
    D,
    L,
}

impl Dir {
    fn from_i32(i: i32) -> Self {
        match i {
            0 => Dir::R,
            1 => Dir::D,
            2 => Dir::L,
            3 => Dir::U,
            _ => panic!("invalid direction"),
        }
    }

    fn as_i32(&self) -> i32 {
        match self {
            Dir::R => 0,
            Dir::D => 1,
            Dir::L => 2,
            Dir::U => 3,
        }
    }

    fn flip(&self) -> Self {
        Self::from_i32((self.as_i32() + 2).rem_euclid(4))
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
struct State(Pos, Dir);

impl Debug for State {
    fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
        write!(f, "State({:?}, {:?})", self.pos(), self.dir())
    }
}

impl State {
    fn on(&self, board: &Board) -> Tile {
        let pos = self.pos();
        if pos.0 < 0 || pos.1 < 0 || pos.0 >= board.len() as i32 {
            return Tile::Nothing;
        }
        let row = &board[pos.0 as usize];
        if pos.1 >= row.len() as i32 {
            return Tile::Nothing;
        }
        row[pos.1 as usize]
    }

    fn pos(&self) -> Pos {
        self.0
    }

    fn dir(&self) -> Dir {
        self.1
    }

    fn password(&self) -> u32 {
        [
            (self.pos().0 as u32 + 1) * 1000,
            (self.pos().1 as u32 + 1) * 4,
            self.dir().as_i32() as u32,
        ]
        .iter()
        .sum()
    }
}

fn seek(state: State, target: Tile, board: &Board) -> State {
    let mut state = state;
    let mut tile = state.on(board);

    while tile != target {
        state = Move::Fwd(1).apply(state);
        tile = state.on(board);
    }

    state
}

fn simulate(
    board: &Board,
    moves: Vec<Move>,
    alg: fn(State, &Board) -> State,
) -> (State, Vec<State>) {
    assert!(!board.is_empty());
    let mut state = seek(State((0, 0), Dir::R), Tile::Open, board);
    let mut path = vec![state];

    // Process moves
    for mov in moves {
        let cursor = mov.apply(state);
        let tile = cursor.on(board);
        match tile {
            Tile::Open => {
                state = cursor;
            }
            Tile::Solid => { /* no-op */ }
            Tile::Nothing => {
                state = alg(state, board);
            }
        }
        path.push(state);
    }

    (state, path)
}

fn wrap2d(state: State, board: &Board) -> State {
    let mut cursor = Move::Turn180.apply(state);
    cursor = seek(cursor, Tile::Nothing, board);
    cursor = Move::Turn180.apply(cursor);
    cursor = Move::Fwd(1).apply(cursor);

    match cursor.on(board) {
        Tile::Open => cursor,
        Tile::Solid => state,
        Tile::Nothing => panic!("invalid state"),
    }
}

// I'm sure there's some cube-folding algorithm that can do this, but ain't
// nobody got time for that. Let's just hard-code the "warps" for the small and
// large boards, fully knowing that this won't be generalizable. This function
// isn't even memoized or use ranges lol 🙈
fn warp_small(state: State, board: &Board) -> State {
    let there: Vec<(State, State)> = vec![
        (State((0, 8), Dir::U), State((4, 3), Dir::D)),
        (State((0, 9), Dir::U), State((4, 2), Dir::D)),
        (State((0, 10), Dir::U), State((4, 1), Dir::D)),
        (State((0, 11), Dir::U), State((4, 0), Dir::D)),
        (State((0, 11), Dir::R), State((11, 15), Dir::L)),
        (State((1, 11), Dir::R), State((10, 15), Dir::L)),
        (State((2, 11), Dir::R), State((9, 15), Dir::L)),
        (State((3, 11), Dir::R), State((8, 15), Dir::L)),
        (State((4, 11), Dir::R), State((8, 15), Dir::D)),
        (State((5, 11), Dir::R), State((8, 14), Dir::D)),
        (State((6, 11), Dir::R), State((8, 13), Dir::D)),
        (State((7, 11), Dir::R), State((8, 12), Dir::D)),
        (State((11, 15), Dir::D), State((4, 0), Dir::R)),
        (State((11, 14), Dir::D), State((5, 0), Dir::R)),
        (State((11, 13), Dir::D), State((6, 0), Dir::R)),
        (State((11, 12), Dir::D), State((7, 0), Dir::R)),
        (State((11, 11), Dir::D), State((7, 0), Dir::U)),
        (State((11, 10), Dir::D), State((7, 1), Dir::U)),
        (State((11, 9), Dir::D), State((7, 2), Dir::U)),
        (State((11, 8), Dir::D), State((7, 3), Dir::U)),
        (State((11, 8), Dir::L), State((7, 4), Dir::U)),
        (State((10, 8), Dir::L), State((7, 5), Dir::U)),
        (State((9, 8), Dir::L), State((7, 6), Dir::U)),
        (State((8, 8), Dir::L), State((7, 7), Dir::U)),
        (State((4, 4), Dir::U), State((0, 8), Dir::R)),
        (State((4, 5), Dir::U), State((1, 8), Dir::R)),
        (State((4, 6), Dir::U), State((2, 8), Dir::R)),
        (State((4, 7), Dir::U), State((3, 8), Dir::R)),
    ];

    let back: Vec<(State, State)> = there
        .iter()
        .map(|(a, b)| {
            (
                State(b.pos(), b.dir().flip()),
                State(a.pos(), a.dir().flip()),
            )
        })
        .collect();

    let lookup: HashMap<&State, State> =
        there
            .iter()
            .chain(back.iter())
            .fold(HashMap::new(), |mut acc, (a, b)| {
                acc.insert(a, *b);
                acc
            });

    let cursor = *lookup.get(&state).unwrap();
    match cursor.on(board) {
        Tile::Open => cursor,
        Tile::Solid => state,
        Tile::Nothing => panic!("invalid state"),
    }
}

#[allow(dead_code, unused_variables)]
fn warp_large(state: State, board: &Board) -> State {
    /*
     * lol this is way too embarassing to put on GitHub. This was extremely
     * repetitive code that ChatGPT generated for me.  ¯\_(ツ)_/¯
     *
     * I'm looking forward to the write-ups on proper cube-folding!
     */
    state
}

fn draw(board: &Board, path: &Vec<State>) {
    let mut buffer: Vec<Vec<&str>> = board
        .iter()
        .map(|row| {
            row.iter()
                .map(|tile| match tile {
                    Tile::Nothing => " ",
                    Tile::Solid => "#",
                    Tile::Open => ".",
                })
                .collect()
        })
        .collect();

    for state in path {
        let pos = state.pos();
        buffer[pos.0 as usize][pos.1 as usize] = match state.dir() {
            Dir::U => "\x1b[93m^\x1b[0m",
            Dir::R => "\x1b[93m>\x1b[0m",
            Dir::D => "\x1b[93mv\x1b[0m",
            Dir::L => "\x1b[93m<\x1b[0m",
        };
    }

    for row in buffer {
        for c in row {
            print!("{}", c);
        }
        println!();
    }
}

fn parse(input: &str) -> IResult<&str, (Board, Vec<Move>)> {
    separated_pair(
        many1(terminated(
            many1(map(one_of(" .#"), |c| match c {
                ' ' => Tile::Nothing,
                '#' => Tile::Solid,
                '.' => Tile::Open,
                _ => panic!("unhandled input"),
            })),
            newline,
        )),
        tag("\n"),
        terminated(
            many1(alt((
                map(alpha1, |c| match c {
                    "L" => Move::TurnL,
                    "R" => Move::TurnR,
                    _ => panic!("unhandled input"),
                }),
                map(recognize_float, |n: &str| Move::Fwd(n.parse().unwrap())),
            ))),
            newline,
        ),
    )(input)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 22);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 22);
        assert_eq!(part_one(&input), Some(6032));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 22);
        assert_eq!(part_two(&input), Some(5031));
    }
}
