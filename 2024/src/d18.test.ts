import { Solver } from "./d18";

const example = `
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0`;

describe("d18 Solver", () => {
  const solver = new Solver(example, 7);

  it("should solve part 1 examples", () => {
    expect(solver.part1(12)).toBe(22);
  });

  it("should solve part 2 examples", () => {
    expect(solver.part2(0)).toBe("6,1");
  });
});
