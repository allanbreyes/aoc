import { Solver } from "./d16";

const simple = `
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############`;

const example = `
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#^#
#.#.#.#...#...#^#
#.#.#.#.###.#.#^#
#>>v#.#.#.....#^#
#^#v#.#.#.#####^#
#^#v..#.#.#>>>>^#
#^#v#####.#^###.#
#^#v#..>>>>^#...#
#^#v###^#####.###
#^#v#>>^#.....#.#
#^#v#^#####.###.#
#^#v#^........#.#
#^#v#^#########.#
#S#>>^..........#
#################`;

describe("d16 Solver", () => {
  it("should solve part 1 examples", () => {
    let solver = new Solver(simple);
    expect(solver.part1()).toBe(7036);

    solver = new Solver(example);
    expect(solver.part1()).toBe(11048);
  });

  it("should solve part 2 examples", () => {
    let solver = new Solver(simple);
    expect(solver.part2()).toBe(45);

    solver = new Solver(example);
    expect(solver.part2()).toBe(64);
  });
});
