import { Solver } from "./d19";

const example = `
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb`;

describe("d19 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(6);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(16);
  });
});
