import { readFileSync } from "fs";

type Position = [number, number];
type Grid = string[][];

export class Solver {
  constructor(private readonly input: string) {}

  part1(threshold = 100) {
    return this.solve(2, threshold);
  }

  part2(threshold = 100) {
    return this.solve(20, threshold);
  }

  solve(size: number, threshold: number) {
    const { grid, start, end } = this.parse();
    const { shortest, dists: startdists } = this.dijkstra(grid, start, end);
    const { dists: enddists } = this.dijkstra(grid, end, start);

    let result = 0;
    for (const [i, j] of this.jumps(grid)) {
      for (const [ni, nj] of this.lands(grid, [i, j], size)) {
        const cheat = Math.abs(ni - i) + Math.abs(nj - j);
        const dist =
          startdists.get(this.key(i, j))! +
          enddists.get(this.key(ni, nj))! +
          cheat;
        if (shortest - dist >= threshold) {
          result++;
        }
      }
    }
    return result;
  }

  *jumps(grid: Grid) {
    for (let i = 1; i < grid.length - 1; i++) {
      for (let j = 1; j < grid[0].length - 1; j++) {
        if (grid[i][j] === ".") {
          yield [i, j] as Position;
        }
      }
    }
  }

  *lands(grid: Grid, pos: Position, size: number = 2) {
    for (let di = -size; di <= size; di++) {
      const left = size - Math.abs(di);
      for (let dj = -left; dj <= left; dj++) {
        if (di === 0 && dj === 0) continue;

        const [i, j] = pos;
        const [ni, nj] = [i + di, j + dj];
        if (ni < 0 || ni >= grid.length || nj < 0 || nj >= grid[0].length) {
          continue;
        } else if (grid[ni][nj] === "#") {
          continue;
        } else {
          yield [ni, nj];
        }
      }
    }
  }

  dijkstra(
    grid: Grid,
    start: Position,
    goal: Position,
    dists = new Map<string, number>(),
  ) {
    const pq: [number, Position, Position[]][] = [[0, start, [start]]];

    const visited = new Set<string>();
    let shortest = Infinity;

    while (pq.length > 0) {
      const [dist, pos, path] = pq.shift()!;
      const [i, j] = pos;
      const key = this.key(i, j);

      if (dist < (dists.get(key) ?? Infinity)) {
        dists.set(key, dist);
      } else {
        continue;
      }

      if (i === goal[0] && j === goal[1] && dist <= shortest) {
        shortest = dist;
        for (const pos of path) {
          visited.add(this.key(...pos));
        }
      }

      for (const [di, dj] of [
        [-1, 0],
        [1, 0],
        [0, -1],
        [0, 1],
      ]) {
        const [ni, nj] = [i + di, j + dj];
        const nkey = this.key(ni, nj);

        if (ni < 0 || ni >= grid.length || nj < 0 || nj >= grid[0].length) {
          continue;
        } else if (grid[ni][nj] === "#") {
          continue;
        }

        if (dist + 1 < (dists.get(nkey) ?? Infinity)) {
          pq.push([dist + 1, [ni, nj], [...path, [ni, nj]]]);
          pq.sort((a, b) => a[0] - b[0]); // A poor man's priority queue...
        }
      }
    }

    return { shortest, visited, dists };
  }

  key(i: number, j: number) {
    return `${i},${j}`;
  }

  private parse() {
    let start: Position = [NaN, NaN];
    let end: Position = [NaN, NaN];
    const grid = this.input
      .trim()
      .split("\n")
      .map((line, i) => {
        return line.split("").map((cell, j) => {
          if (cell === "S") {
            start = [i, j];
            return ".";
          }
          if (cell === "E") {
            end = [i, j];
            return ".";
          }
          return cell;
        });
      });

    return { grid, start, end };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/20.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
