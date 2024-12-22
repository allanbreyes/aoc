import { Solver } from "./d22";

const example1 = `
1
10
100
2024`;

const example2 = `
1
2
3
2024`;

describe("d22 Solver", () => {
  it("should solve part 1 examples", () => {
    const solver = new Solver(example1);
    expect(solver.part1()).toBe(37327623);
  });

  it("should solve part 2 examples", () => {
    const solver = new Solver(example2);
    expect(solver.part2()).toBe(23);
  });
});
