import { readFileSync } from "fs";

export class Solver {
  constructor(private input: string) {}

  part1() {
    return this.parse().length;
  }

  part2() {
    return this.parse().length;
  }

  private parse() {
    return this.input.trim().split("\n");
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/00.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}