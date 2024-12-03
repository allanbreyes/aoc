import { readFileSync } from "fs";

export class Solver {
  constructor(private input: string) {}

  part1() {
    return this.parse().flatMap(line => {
      return line.match(/mul\(-?\d+,-?\d+\)/g);
    }).map(mul => {
      const [a, b] = mul?.split(/[(),]/).slice(1, 3).map(Number) ?? [0, 0];
      return a * b;
    }).reduce((a, b) => a + b, 0);
  }

  part2() {
    let enabled = true;
    let sum = 0;
    this.parse().flatMap(line => {
      return line.match(/(mul\(-?\d+,-?\d+\)|do\(\)|don't\(\))/g);
    }).forEach(ins => {
      const op = ins?.match(/^.+?(?=\()/)?.[0];
      switch (op) {
        case "mul":
          if (enabled) {
            const [a, b] = ins?.split(/[(),]/).slice(1, 3).map(Number) ?? [0, 0];
            sum += a * b;
          }
          break;
        case "do":
          enabled = true;
          break;
        case "don't":
          enabled = false;
          break;
      }
    });
    return sum;
  }

  private parse() {
    return this.input.trim().split("\n");
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/03.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}