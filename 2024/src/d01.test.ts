import { Solver } from "./d01";

const example = `3   4
4   3
2   5
1   3
3   9
3   3`;

describe("Day 01", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(11);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(31);
  });
});
