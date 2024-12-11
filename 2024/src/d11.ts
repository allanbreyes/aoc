import { readFileSync } from "fs";
import { Cache } from "./utils";

export class Solver {
  cache: Cache<number, number> = new Cache();

  constructor(private input: string) {}

  part1() {
    return this.solve(this.parse(), 25);
  }

  part2() {
    return this.solve(this.parse(), 75);
  }

  solve(stones: number[], n: number) {
    return stones.reduce((acc, stone) => {
      return acc + this.count(stone, n);
    }, 0);
  }

  count(stone: number, n: number): number {
    if (this.cache.has(stone, n)) {
      return this.cache.get(stone, n);
    }

    if (n === 0) {
      this.cache.set(1, stone, n);
      return 1;
    }

    let result;
    const digits = Math.floor(Math.log10(stone)) + 1;
    if (stone === 0) {
      result = this.count(1, n - 1);
    } else if (digits % 2 === 0) {
      result =
        this.count(Math.floor(stone / 10 ** (digits / 2)), n - 1) +
        this.count(Math.floor(stone % 10 ** (digits / 2)), n - 1);
    } else {
      result = this.count(stone * 2024, n - 1);
    }

    this.cache.set(result, stone, n);
    return result;
  }

  parse() {
    return this.input.trim().split(" ").map(Number);
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/11.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
