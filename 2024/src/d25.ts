import { readFileSync } from "fs";

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    const { locks, keys } = this.parse();

    return locks.reduce((acc, lock) => {
      return (
        acc +
        keys.reduce((acc, key) => {
          return acc + (lock.every((h, i) => h + key[i] <= 5) ? 1 : 0);
        }, 0)
      );
    }, 0);
  }

  part2() {
    return "⭐";
  }

  private parse() {
    const locks: number[][] = [];
    const keys: number[][] = [];
    this.input
      .trim()
      .split("\n\n")
      .forEach((stanza) => {
        const schematic = stanza.split("\n");
        const n = schematic.length;
        const heights: number[] = Array.from(
          { length: schematic[0].length },
          () => -1,
        );

        let group: number[][];
        if (schematic[0].match("#+") && schematic[n - 1].match("\.+")) {
          group = locks;
        } else if (schematic[0].match("\.+") && schematic[n - 1].match("#+")) {
          group = keys;
        } else {
          throw new Error(`Unexpected input: ${stanza}`);
        }

        for (let i = 0; i < n; i++) {
          for (let j = 0; j < schematic[i].length; j++) {
            if (schematic[i][j] === "#") {
              heights[j]++;
            }
          }
        }

        group.push(heights);
      });

    return { locks, keys };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/25.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
