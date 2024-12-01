import { readFileSync } from "fs";

export class Solver {
  constructor(private input: string) {}

  part1() {
    const [left, right] = this.parse();
    left.sort((a, b) => a - b);
    right.sort((a, b) => a - b);

    let dist = 0;
    for (let i = 0; i < left.length; i++) {
      dist += Math.abs(left[i] - right[i]);
    }
    return dist;
  }

  part2() {
    const [left, right] = this.parse();

    const counter = right.reduce((acc, val) => {
      acc[val] = (acc[val] || 0) + 1;
      return acc;
    }, {} as Record<number, number>);

    return left.reduce((acc, val) => {
      if (counter[val] > 0) {
        acc += val * counter[val];
      }
      return acc;
    }, 0);
  }

  private parse() {
    const rows = this.input.trim().split("\n").map((line) => {
      const [a, b] = line.split("   ");
      return [parseInt(a, 10), parseInt(b, 10)];
    });
    const left = rows.map(row => row[0]);
    const right = rows.map(row => row[1]);
    return [left, right];
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/01.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}