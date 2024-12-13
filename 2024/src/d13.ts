import { readFileSync } from "fs";

const COST_A = 3;
const COST_B = 1;
const OFFSET = 10000000000000;

type Tuple = [number, number];
type Machine = [Tuple, Tuple, Tuple];

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    return this.parse().reduce((acc, machine) => acc + this.solve(machine), 0);
  }

  part2() {
    return this.parse(OFFSET).reduce(
      (acc, machine) => acc + this.solve(machine),
      0,
    );
  }

  cost(press: Tuple): number {
    return press[0] * COST_A + press[1] * COST_B;
  }

  solve(machine: Machine): number {
    const [a, b, p] = machine;

    const d = a[0] * b[1] - b[0] * a[1];
    if (
      d !== 0 &&
      (b[1] * p[0] - b[0] * p[1]) % d == 0 &&
      (a[0] * p[1] - a[1] * p[0]) % d == 0
    ) {
      return this.cost([
        (b[1] * p[0] - b[0] * p[1]) / d,
        (a[0] * p[1] - a[1] * p[0]) / d,
      ]);
    }

    return 0;
  }

  private parse(offset = 0): Machine[] {
    return this.input
      .trim()
      .split("\n\n")
      .map((stanza) => {
        return stanza.split("\n").map((line, i) => {
          return Array.from(line.matchAll(/.*: X[+=](\d+), Y[+=](\d+)/g))[0]
            .slice(1)
            .map(Number)
            .map((n) => (i === 2 ? n + offset : n));
        }) as Machine;
      });
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/13.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
