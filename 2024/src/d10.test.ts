import { Solver } from "./d10";

const example = `89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732`;

describe("d10 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(36);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(81);
  });
});
