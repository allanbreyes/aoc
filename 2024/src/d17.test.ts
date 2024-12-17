import { Solver } from "./d17";

const example1 = `
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0`;

const example2 = `
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0`;

describe("d17 Solver", () => {
  it("implements part 1 opcodes correctly", () => {
    const solver = new Solver("");

    // If register C contains 9, the program 2,6 would set register B to 1.
    solver.clear();
    solver.registers.set("C", BigInt(9));
    expect(solver.bst2(6)).toEqual(BigInt(1));
    expect(solver.registers.get("B")).toEqual(BigInt(1));

    // If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
    solver.clear();
    solver.registers.set("A", BigInt(10));
    solver.program = [5, 0, 5, 1, 5, 4];
    expect(solver.run()).toEqual([0, 1, 2]);

    // If register A contains 2024, the program 0,1,5,4,3,0 would output
    // 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
    solver.clear();
    solver.registers.set("A", BigInt(2024));
    solver.program = [0, 1, 5, 4, 3, 0];
    expect(solver.run()).toEqual([4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0]);
    expect(solver.registers.get("A")).toEqual(BigInt(0));

    // If register B contains 29, the program 1,7 would set register B to 26.
    solver.clear();
    solver.registers.set("B", BigInt(29));
    solver.program = [1, 7];
    solver.run();
    expect(solver.registers.get("B")).toEqual(BigInt(26));

    // If register B contains 2024 and register C contains 43690, the program
    // 4,0 would set register B to 44354.
    solver.clear();
    solver.registers.set("B", BigInt(2024));
    solver.registers.set("C", BigInt(43690));
    solver.program = [4, 0];
    solver.run();
    expect(solver.registers.get("B")).toEqual(BigInt(44354));
  });

  it("should solve part 1 examples", () => {
    const solver = new Solver(example1);
    expect(solver.part1()).toBe("4,6,3,5,6,3,5,2,1,0");
  });

  it("should solve part 2 examples", () => {
    const solver = new Solver(example2);
    expect(solver.part2()).toBe(117440);
  });
});
