import { Solver } from "./d12";

const example = `
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE`;

describe("d12 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(1930);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2()).toBe(1206);
  });
});
