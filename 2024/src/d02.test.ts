import { Solver } from "./d02";

const example = `7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9`;

describe("d02 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(2);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(4);
  });
});
