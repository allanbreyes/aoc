import { Solver } from "./d00";

const example = `foo
bar
baz`;

describe("d00 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(3);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(3);
  });
});
