import { readFileSync } from "fs";

type Position = [number, number];
type Direction = 0 | 1 | 2 | 3;
type Vector = [number, number, Direction];

const DELTA = [
  [-1, 0], // 0: N
  [0, 1], // 1: E
  [1, 0], // 2: S
  [0, -1], // 3: W
];

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    const { grid, start, goal } = this.parse();
    const { best } = this.dijkstra(grid, [...start, 1], goal);
    return best;
  }

  part2() {
    const { grid, start, goal } = this.parse();
    const { visited } = this.dijkstra(grid, [...start, 1], goal);
    return visited.size;
  }

  dijkstra(grid: string[][], start: Vector, goal: Position) {
    const dists = new Map<string, number>();
    const pq: [number, Vector, Position[]][] = [
      [0, start, [start.slice(0, 2) as Position]],
    ];

    const visited = new Set<string>();
    let best = Infinity;

    while (pq.length > 0) {
      const [dist, vec, path] = pq.shift()!;
      const [i, j, d] = vec;

      // Update the distance if we have a shorter or equivalent path
      if (dist <= (dists.get(this.key(...vec)) ?? Infinity)) {
        dists.set(this.key(...vec), dist);
      } else {
        continue;
      }

      // Update the visited set (for part 2)
      if (i === goal[0] && j === goal[1] && dist <= best) {
        best = dist;
        for (const pos of path) {
          visited.add(this.key(...pos));
        }
      }

      const [left, right] = [d - 1, d + 1].map((x) => (x + 4) % 4);

      for (const [di, dj, nd, cost] of [
        [...DELTA[d], d, 1],
        [...DELTA[left], left, 1_000 + 1],
        [...DELTA[right], right, 1_000 + 1],
      ]) {
        const [nj, ni] = [j + dj, i + di];
        const npos: Position = [ni, nj];
        const nvec: Vector = [ni, nj, nd as Direction];
        if (
          grid[ni][nj] === "#" || // Wall
          visited.has(this.key(...npos)) || // Already on optimal path
          dist + cost > best // No need to explore further
        )
          continue;

        pq.push([dist + cost, nvec, path.concat([npos])]);
        pq.sort((a, b) => a[0] - b[0]); // A poor man's priority queue...
      }
    }

    return { best, visited };
  }

  key(...args: number[]) {
    return args.join(",");
  }

  unkey(key: string) {
    return key.split(",").map(Number);
  }

  draw(grid: string[][], path: Position[]) {
    const copy = grid.map((row) => [...row]);
    for (const [i, j] of path) {
      copy[i][j] = "o";
    }
    console.log(copy.map((row) => row.join("")).join("\n"));
  }

  private parse() {
    let start: Position = [NaN, NaN];
    let goal: Position = [NaN, NaN];

    const grid = this.input
      .trim()
      .split("\n")
      .map((line, i) => {
        return line.split("").map((c, j) => {
          if (c === "S") {
            start = [i, j];
            return ".";
          } else if (c === "E") {
            goal = [i, j];
            return ".";
          } else {
            return c;
          }
        });
      });

    return { grid, start, goal };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/16.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
