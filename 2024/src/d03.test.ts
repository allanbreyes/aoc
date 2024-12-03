import { Solver } from './d03';

const example1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
const example2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

describe("d03 Solver", () => {
  it("should solve part 1 examples", () => {
    const solver = new Solver(example1);
    expect(solver.part1()).toBe(161);
  });

  it("should solve part 2 examples", () => {
    const solver = new Solver(example2);
    expect(solver.part2()).toBe(48);
  });
});