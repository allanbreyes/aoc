import { Solver } from "./d06";

const example = `....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...`;

describe("d06 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(41);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(6);
  });
});
