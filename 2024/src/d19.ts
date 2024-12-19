import { readFileSync } from "fs";

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    return this.solve(...this.parse(), (acc, _) => acc + 1);
  }

  part2() {
    return this.solve(...this.parse(), (acc, result) => acc + result);
  }

  solve(
    towels: Set<string>,
    patterns: string[],
    aggregator: (acc: number, result: number) => number,
  ) {
    return patterns.reduce((acc, pattern) => {
      const result = this.make(pattern, towels);
      return result > 0 ? aggregator(acc, result) : acc;
    }, 0);
  }

  make(
    pattern: string,
    towels: Set<string>,
    memo: Map<string, number> = new Map<string, number>(),
  ): number {
    if (memo.has(pattern)) return memo.get(pattern)!;

    let ways = towels.has(pattern) ? 1 : 0;
    for (let i = pattern.length - 1; i > 0; i--) {
      const subpattern = pattern.slice(0, i);
      if (towels.has(subpattern)) {
        ways += this.make(pattern.slice(i), towels, memo);
      }
    }

    memo.set(pattern, ways);
    return ways;
  }

  parse() {
    return this.input
      .trim()
      .split("\n\n")
      .map((stanza, i) => {
        if (i === 0) {
          return stanza
            .trim()
            .split(", ")
            .reduce((acc, towel) => {
              acc.add(towel);
              return acc;
            }, new Set<string>());
        } else if (i === 1) {
          return stanza.trim().split("\n");
        } else {
          throw new Error(`unexpected stanza: ${stanza}`);
        }
      }) as [Set<string>, string[]];
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/19.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
