import { Solver } from "./d20";

const example = `
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############`;

describe("d20 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", async () => {
    expect(solver.part1(20)).toBe(5);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2(70)).toBe(41);
  });
});
