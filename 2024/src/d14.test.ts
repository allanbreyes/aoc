import { Solver } from "./d14";

const example = `
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3`;

describe("d14 Solver", () => {
  const solver = new Solver(example, [11, 7]);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(12);
  });
});
