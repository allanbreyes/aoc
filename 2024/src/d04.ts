import { readFileSync } from "fs";

export class Solver {
  constructor(private input: string) {}

  part1() {
    const XMAS = "XMAS".split("");
    const grid = this.parse();

    let matches = 0;

    grid.forEach((row, i) => {
      row.forEach((char, j) => {
        if (char === XMAS[0]) {
          [
            [0, 1], // E
            [1, 1], // SE
            [1, 0], // S
            [1, -1], // SW
            [0, -1], // W
            [-1, -1], // NW
            [-1, 0], // N
            [-1, 1], // NE
          ].forEach(([di, dj]) => {
            if (this.search(grid, i, j, XMAS, di, dj)) {
              matches++;
            }
          });
        }
      });
    });

    return matches;
  }

  part2() {
    const grid = this.parse();

    let matches = 0;

    grid.forEach((row, i) => {
      row.forEach((char, j) => {
        if (char == "A") {
          if (this.cross(grid, i, j)) {
            matches++;
          }
        }
      });
    });

    return matches;
  }

  search(
    grid: string[][],
    i: number,
    j: number,
    search: string[],
    di: number,
    dj: number,
  ) {
    const rows = grid.length;
    const cols = grid[0].length;

    for (let k = 0; k < search.length; k++) {
      // Out of bounds
      if (i < 0 || i >= rows || j < 0 || j >= cols) {
        return false;
      }

      // Mismatch
      if (grid[i][j] !== search[k]) {
        return false;
      }

      i += di;
      j += dj;
    }
    return true;
  }

  cross(grid: string[][], i: number, j: number) {
    const rows = grid.length;
    const cols = grid[0].length;

    // Out of bounds
    if (i - 1 < 0 || i + 1 >= rows || j - 1 < 0 || j + 1 >= cols) {
      return false;
    }

    const [nw, ne, sw, se] = [
      grid[i - 1][j - 1],
      grid[i - 1][j + 1],
      grid[i + 1][j - 1],
      grid[i + 1][j + 1],
    ];

    const combos = ["MS-MS", "MS-SM", "SM-SM", "SM-MS"];
    return combos.indexOf([nw, se, "-", sw, ne].join("")) !== -1;
  }

  private parse(): string[][] {
    return this.input
      .trim()
      .split("\n")
      .map((line) => line.split(""));
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/04.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
