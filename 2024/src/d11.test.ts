import { Solver } from "./d11";

const example = `125 17`;

describe("d11 Solver", () => {
  const solver = new Solver(example);

  describe("count", () => {
    it("produces the correct results", () => {
      expect(solver.count(0, 1)).toBe(1);
      expect(solver.count(0, 2)).toBe(1);
      expect(solver.count(0, 3)).toBe(2);
      expect(solver.count(0, 4)).toBe(4);
      expect(solver.count(0, 5)).toBe(4);
      expect(solver.count(0, 6)).toBe(7);
      expect(solver.count(0, 8)).toBe(16);
    });
  });

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(55312);
  });
});
