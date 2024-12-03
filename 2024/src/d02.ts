import { readFileSync } from "fs";

export class Solver {
  constructor(private input: string) {}

  part1() {
    return this.parse().filter(Solver.isSafe).length;
  }

  part2() {
    return this.parse().filter((level) => {
      if (Solver.isSafe(level)) {
        return true;
      }

      for (let i = 0; i < level.length; i++) {
        const copy = level.slice();
        copy.splice(i, 1);
        if (Solver.isSafe(copy)) {
          return true;
        }
      }

      return false;
    }).length;
  }

  private static isSafe(level: number[]) {
    let increasing: boolean;
    if (level[0] < level[1]) {
      increasing = true;
    } else if (level[0] > level[1]) {
      increasing = false;
    } else {
      return false;
    }

    for (let j = 1; j < level.length; j++) {
      const a = level[j - 1];
      const b = level[j];

      if ((increasing ? a > b : a < b) || a === b || Math.abs(a - b) > 3) {
        return false;
      }
    }
    return true;
  }

  private parse() {
    return this.input
      .trim()
      .split("\n")
      .map((line) => line.split(" ").map(Number));
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/02.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
