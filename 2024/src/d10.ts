import { readFileSync } from "fs";

type Point = [number, number];

export class Solver {
  grid: number[][];
  trailheads: Point[];
  rows: number;
  cols: number;

  constructor(private input: string) {
    const { grid, trailheads } = this.parse();
    this.grid = grid;
    this.trailheads = trailheads;
    this.rows = grid.length;
    this.cols = grid[0].length;
  }

  part1() {
    return this.trailheads.reduce((acc, trailhead) => {
      const trails = this.getTrails([trailhead]);
      const peaks = trails.reduce((acc, trail) => {
        acc.add(JSON.stringify(trail.at(-1)));
        return acc;
      }, new Set<string>());
      return acc + peaks.size;
    }, 0);
  }

  part2() {
    return this.trailheads.reduce((acc, trailhead) => {
      return acc + this.getTrails([trailhead]).length;
    }, 0);
  }

  private getTrails(trail: Point[]): Point[][] {
    if (trail.length === 0) {
      throw new Error("Empty trail");
    }
    const [i, j] = trail.at(-1)!;

    // Base case
    if (this.grid[i][j] === 9) {
      return [trail];
    }

    // Recursive case
    const neighbors = [
      [i - 1, j],
      [i + 1, j],
      [i, j - 1],
      [i, j + 1],
    ];
    return neighbors.reduce((acc, [ni, nj]) => {
      if (ni < 0 || ni >= this.rows || nj < 0 || nj >= this.cols) {
        return acc;
      }
      const nh = this.grid[ni][nj];
      if (nh - this.grid[i][j] === 1) {
        return [...acc, ...this.getTrails([[ni, nj]])];
      }
      return acc;
    }, [] as Point[][]);
  }

  private parse() {
    const trailheads: Point[] = [];
    const grid: number[][] = [];
    this.input
      .trim()
      .split("\n")
      .forEach((line, i) => {
        const row: number[] = [];
        line.split("").forEach((cell, j) => {
          const value = parseInt(cell, 10);
          if (value === 0) trailheads.push([i, j]);
          row.push(value);
        });
        grid.push(row);
      });

    return { grid, trailheads };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/10.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
