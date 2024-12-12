import { readFileSync } from "fs";

export class Solver {
  grid: string[][];

  constructor(private input: string) {
    this.grid = this.parse();
  }

  part1() {
    let sum = 0;

    this.partition().forEach((plot) => {
      const [i, j] = this.unpack(plot)[0];
      const edges = this.perimeter(i, j, plot);
      sum += plot.size * edges.size;
    });

    return sum;
  }

  part2() {
    let sum = 0;

    this.partition().forEach((plot) => {
      const [i, j] = this.unpack(plot)[0];
      const edges = this.perimeter(i, j, plot);
      const sides = this.sides(edges);
      sum += plot.size * sides;
    });

    return sum;
  }

  partition(): Set<string>[] {
    const plots: Set<string>[] = [];
    let visited: Set<string> = new Set();

    this.grid.forEach((row, i) => {
      if (i === 0 || i === this.grid.length - 1) return;
      row.forEach((_, j) => {
        if (j === 0 || j === this.grid[0].length - 1) return;

        if (visited.has(this.key(i, j))) return;
        const plot = this.flood(i, j);
        plots.push(plot);
        visited = new Set([...visited, ...plot]);
      });
    });

    return plots;
  }

  flood(
    i: number,
    j: number,
    rune: string | null = null,
    visited: Set<string> = new Set<string>(),
  ): Set<string> {
    if (rune === null) {
      rune = this.grid[i][j];
    } else if (this.grid[i][j] !== rune) {
      return visited;
    }

    if (this.grid[i][j] === "#" || this.grid[i][j] !== rune) {
      return visited;
    }

    if (visited.has(this.key(i, j))) {
      return visited;
    }

    visited.add(this.key(i, j));

    return new Set([
      ...this.flood(i + 1, j, rune, visited),
      ...this.flood(i - 1, j, rune, visited),
      ...this.flood(i, j + 1, rune, visited),
      ...this.flood(i, j - 1, rune, visited),
    ]);
  }

  perimeter(
    i: number,
    j: number,
    plot: Set<string>,
    rune: string | null = null,
    edges: Set<string> = new Set<string>(),
    visited: Set<string> = new Set<string>(),
  ): Set<string> {
    if (rune === null) {
      rune = this.grid[i][j];
    }

    if (this.grid[i][j] !== rune) {
      return edges;
    }

    if (visited.has(this.key(i, j))) {
      return edges;
    }

    visited.add(this.key(i, j));

    const neighbors = [
      this.grid[i - 1][j], // N
      this.grid[i][j + 1], // E
      this.grid[i + 1][j], // S
      this.grid[i][j - 1], // W
    ];
    neighbors.forEach((neighbor, dir) => {
      if (neighbor !== rune) {
        edges.add(this.key(i, j, dir));
      }
    });

    return new Set([
      ...this.perimeter(i + 1, j, plot, rune, edges, visited),
      ...this.perimeter(i - 1, j, plot, rune, edges, visited),
      ...this.perimeter(i, j + 1, plot, rune, edges, visited),
      ...this.perimeter(i, j - 1, plot, rune, edges, visited),
    ]);
  }

  sides(edges: Set<string>) {
    let count = 0;

    while (edges.size > 0) {
      let [i, j, dir] = this.unpack(edges)[0];
      edges.delete(this.key(i, j, dir));
      count++;

      if (dir === 0 || dir === 2) {
        // E
        let d = 1;
        while (edges.has(this.key(i, j + d, dir))) {
          edges.delete(this.key(i, j + d, dir));
          d++;
        }

        // W
        d = -1;
        while (edges.has(this.key(i, j + d, dir))) {
          edges.delete(this.key(i, j + d, dir));
          d--;
        }
      } else if (dir === 1 || dir === 3) {
        // N
        let d = -1;
        while (edges.has(this.key(i + d, j, dir))) {
          edges.delete(this.key(i + d, j, dir));
          d--;
        }

        // S
        d = 1;
        while (edges.has(this.key(i + d, j, dir))) {
          edges.delete(this.key(i + d, j, dir));
          d++;
        }
      }
    }

    return count;
  }

  private key(...args: number[]) {
    return args.join(",");
  }

  private unpack(set: Set<string>) {
    return Array.from(set).map((key) => key.split(",").map(Number));
  }

  private parse() {
    return this.pad(
      this.input
        .trim()
        .split("\n")
        .map((line) => line.split("")),
    );
  }

  private pad(grid: string[][]) {
    const newGrid = grid.map((row) => ["#", ...row, "#"]);
    newGrid.unshift(new Array(newGrid[0].length).fill("#"));
    newGrid.push(new Array(newGrid[0].length).fill("#"));
    return newGrid;
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/12.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
