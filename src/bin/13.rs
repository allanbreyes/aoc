use std::cmp::Ordering;
use std::fmt::{Display, Formatter};

use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{multispace0, newline, u32},
    combinator::{map, opt},
    multi::{many0, separated_list0},
    sequence::{delimited, pair, terminated},
    IResult,
};

pub fn part_one(input: &str) -> Option<usize> {
    let (_, pairs) = parse_pairs(input).unwrap();
    let sum = pairs
        .iter()
        .enumerate()
        .fold(0, |acc, (i, pair)| {
            let (l, r) = pair;
            if l < r {
                acc + i + 1
            } else {
                acc
            }
        });
        
    Some(sum)
}

pub fn part_two(input: &str) -> Option<usize> {
    let (_, packets) = parse_all(input).unwrap();
    let mut packets = packets;

    packets.push(divider(2));
    packets.push(divider(6));
    packets.sort();

    let product = &packets
        .clone()
        .iter()
        .enumerate()
        .fold(1, |acc, (i, packet)| {
            if packet == &divider(2) || packet == &divider(6) {
                acc * (i + 1)
            } else {
                acc
            }
        });
    Some(*product)
}

fn divider(i: u32) -> Packet {
    Packet::List(vec![Packet::Integer(i)])
}

#[derive(Clone, Debug, Eq, PartialEq)]
enum Packet {
    Integer(u32),
    List(Vec<Packet>),
}

impl Display for Packet {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        match self {
            Packet::Integer(i) => write!(f, "{}", i),
            Packet::List(l) => {
                write!(f, "[")?;
                for (i, item) in l.iter().enumerate() {
                    if i > 0 {
                        write!(f, ",")?;
                    }
                    write!(f, "{}", item)?;
                }
                write!(f, "]")
            },
        }
    }
}

impl Ord for Packet {
    fn cmp(&self, other: &Self) -> Ordering {
        self.partial_cmp(other).unwrap()
    }
}

impl PartialOrd for Packet {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        match (self, other) {
            // If both values are integers, the lower integer should come first
            (Packet::Integer(a), Packet::Integer(b)) => a.partial_cmp(b),

            // If both values are lists, compare the first value of each list,
            // then the second value, and so on. If the left list runs out of
            // items first, the inputs are in the right order. If the right list
            // runs out of items first, the inputs are not in the right order.
            // If the lists are the same length and no comparison makes a
            // decision about the order, continue checking the next part of the
            // input.
            (Packet::List(l), Packet::List(r)) => {
                for (a, b) in l.iter().zip(r) {
                    let cmp = a.partial_cmp(b);
                    if cmp.is_some() && cmp.unwrap() != Ordering::Equal {
                        return cmp;
                    }
                }

                l.len().partial_cmp(&r.len())
            },

            // If exactly one value is an integer, convert the integer to a list
            // which contains that integer as its only value, then retry the
            // comparison.
            (Packet::List(_), Packet::Integer(_)) => self.partial_cmp(&Packet::List(vec![other.clone()])),
            (Packet::Integer(_), Packet::List(_)) => Packet::List(vec![self.clone()]).partial_cmp(other),
        }
    }
}

fn parse_packet(input: &str) -> IResult<&str, Packet> {
    alt((
        map(
            u32, 
            Packet::Integer,
        ),
        map(
            delimited(
                tag("["),
                separated_list0(
                    tag(","),
                    parse_packet
                ),
                tag("]")),
            Packet::List,
        ),
    ))(input)
}

fn parse_pair(input: &str) -> IResult<&str, (Packet, Packet)> {
    pair(
        terminated(parse_packet, multispace0),
        terminated(parse_packet, multispace0),
    )(input)
}

fn parse_pairs(input: &str) -> IResult<&str, Vec<(Packet, Packet)>> {
    many0(
        terminated(
            parse_pair,
            opt(newline),
        )
    )(input)
}

fn parse_all(input: &str) -> IResult<&str, Vec<Packet>> {
    many0(terminated(parse_packet, opt(multispace0)))(input)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 13);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::cmp::Ordering::{Equal, Greater, Less};

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 13);
        assert_eq!(part_one(&input), Some(13));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 13);
        assert_eq!(part_two(&input), Some(140));
    }

    #[test]
    fn test_partial_cmp() {
        let a = Packet::Integer(1);
        let b = Packet::Integer(2);
        assert_eq!(a.partial_cmp(&b), Some(Less));
        assert_eq!(a.partial_cmp(&a), Some(Equal));
        assert_eq!(b.partial_cmp(&a), Some(Greater));

        let a = Packet::List(vec![Packet::Integer(1)]);
        let b = Packet::List(vec![Packet::Integer(2)]);
        assert_eq!(a.partial_cmp(&b), Some(Less));
        assert_eq!(a.partial_cmp(&a), Some(Equal));
        assert_eq!(b.partial_cmp(&a), Some(Greater));

        let a = Packet::List(vec![Packet::Integer(0); 3]);
        let b = Packet::Integer(2);
        assert_eq!(a.partial_cmp(&b), Some(Less));
        assert_eq!(b.partial_cmp(&a), Some(Greater));

        let a = Packet::Integer(2);
        let b = Packet::List(vec![Packet::Integer(2); 2]);
        assert_eq!(a.partial_cmp(&b), Some(Less));
        assert_eq!(b.partial_cmp(&a), Some(Greater));
    }
}
