import { readFileSync } from "fs";

class RuleBook extends Map<number, Set<number>> {
  lookup(page: number): Set<number> {
    return this.get(page) || new Set<number>();
  }

  write(page: number, rule: number) {
    if (!this.has(page)) {
      this.set(page, new Set<number>());
    }
    this.get(page)!.add(rule);
  }
}

type Update = number[];

export class Solver {
  rules: RuleBook;
  updates: Update[];

  constructor(private input: string) {
    const { rules, updates } = this.parse();
    this.rules = rules;
    this.updates = updates;
  }

  part1() {
    const [valid, _invalid] = this.evaluate();
    return valid.reduce(
      (acc, update) => acc + update[Math.floor(update.length / 2)],
      0,
    );
  }

  part2() {
    const [_valid, invalid] = this.evaluate();
    return invalid.reduce(
      (acc, update) =>
        acc + this.reorder(update)[Math.floor(update.length / 2)],
      0,
    );
  }

  isEqual(a: Update, b: Update): boolean {
    return a.length === b.length ? a.every((x, i) => x === b[i]) : false;
  }

  evaluate(): [Update[], Update[]] {
    const valid: Update[] = [];
    const invalid: Update[] = [];

    this.updates.forEach((update) => {
      const reordered = this.reorder(update);
      (this.isEqual(update, reordered) ? valid : invalid).push(update);
    });

    return [valid, invalid];
  }

  reorder(update: Update): Update {
    return [...update].sort((a, b) => (this.rules.lookup(a).has(b) ? -1 : 1));
  }

  parse() {
    const [top, bottom] = this.input.trim().split("\n\n");

    return {
      rules: top
        .split("\n")
        .map((line) => line.split("|").map(Number))
        .reduce((acc, [a, b]) => {
          acc.write(a, b);
          return acc;
        }, new RuleBook()),

      updates: bottom
        .split("\n")
        .map((update) => update.split(",").map(Number)),
    };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/05.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
