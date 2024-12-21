import { Solver } from "./d21";

const example = `
029A
980A
179A
456A
379A`;

describe("d21 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(126384);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(154115708116294);
  });
});
