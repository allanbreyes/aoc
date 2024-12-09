import { Solver } from "./d09";

const simple = "12345";
const example = "2333133121414131402";

describe("d09 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(1928);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(2858);
  });
});
