import { readFileSync } from "fs";

type Pad = string[][];
type Position = [number, number];

const KEYPAD = [
  ["7", "8", "9"],
  ["4", "5", "6"],
  ["1", "2", "3"],
  [" ", "0", "A"],
];

const DIRPAD = [
  [" ", "^", "A"],
  ["<", "v", ">"],
];

export class Solver {
  cache: Record<string, number> = {};
  constructor(private readonly input: string) {}

  part1() {
    return this.solve(3);
  }

  part2() {
    return this.solve(26);
  }

  solve(n: number = 3) {
    this.cache = {};
    return this.parse().reduce((acc, code) => {
      const length = this.expand(code, n, KEYPAD);
      const complexity = length * parseInt(code.replace(/^\D+/g, ""), 10);
      return acc + complexity;
    }, 0);
  }

  expand(seq: string, n: number, pad: Pad = DIRPAD) {
    if (n === 0) return seq.length;

    let pos = this.find(pad, "A");
    return seq.split("").reduce((acc, chr) => {
      const tgt = this.find(pad, chr);
      const move = this.move(pos, tgt, n, pad);
      pos = tgt;
      return acc + move;
    }, 0);
  }

  move(src: Position, dst: Position, n: number, pad: Pad = DIRPAD) {
    const key = this.key(src, dst, n);
    if (this.cache[key]) return this.cache[key];

    let best = Infinity;
    const queue: Array<[Position, string]> = [[src, ""]];

    while (queue.length > 0) {
      const [pos, path] = queue.shift()!;
      const [i, j] = pos;

      if (this.isSame(pos, dst)) {
        // Expand out with DIRPAD from here on out (drop KEYPAD)
        best = Math.min(best, this.expand(path + "A", n - 1));
        continue;
      } else if (pad[i][j] === " ") {
        // Hovering over gaps results in a panic
        continue;
      }

      const [di, dj] = [dst[0] - i, dst[1] - j];
      if (Math.abs(di) > 0) {
        queue.push([[i + Math.sign(di), j], path + (di > 0 ? "v" : "^")]);
      }
      if (Math.abs(dj) > 0) {
        queue.push([[i, j + Math.sign(dj)], path + (dj > 0 ? ">" : "<")]);
      }
    }

    this.cache[key] = best;
    return best;
  }

  key(...args: Array<number | number[]>) {
    return args.flat().join(",");
  }

  find(pad: Pad, chr: string): Position {
    for (let i = 0; i < pad.length; i++) {
      for (let j = 0; j < pad[i].length; j++) {
        if (pad[i][j] === chr) {
          return [i, j];
        }
      }
    }
    throw new Error(`Could not find ${chr} in pad`);
  }

  isSame(pos1: Position, pos2: Position) {
    return pos1[0] === pos2[0] && pos1[1] === pos2[1];
  }

  private parse() {
    return this.input.trim().split("\n");
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/21.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
