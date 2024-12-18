import { readFileSync } from "fs";

type Position = [number, number];
type Memory = number[][];

export class Solver {
  dim: number;

  constructor(
    private readonly input: string,
    dim: number = 71,
  ) {
    this.dim = dim;
  }

  part1(t: number = 1024) {
    const mems = this.project(this.parse());
    const [start, goal]: Position[] = [
      [0, 0],
      [this.dim - 1, this.dim - 1],
    ];

    const mem = mems[t];
    const { shortest, visited } = this.dijkstra(mem, start, goal);

    if (this.dim > 10) this.draw(mem, visited);
    return shortest;
  }

  part2(t0: number = 1024) {
    const bytes = this.parse();
    const mems = this.project(bytes);
    const [start, goal]: Position[] = [
      [0, 0],
      [this.dim - 1, this.dim - 1],
    ];

    // We could do binary search here or something like union find, but the
    // input is small enough that we can just brute force it with the same
    // pathfinding logic as part 1. At the very least, we can start from the
    // part 1 time since we know that's solvable.
    for (let t = t0; t < mems.length; t++) {
      const mem = mems[t];
      const { shortest } = this.dijkstra(mem, start, goal);

      if (shortest === Infinity) {
        const byte = bytes[t - 1];
        return `${byte[1]},${byte[0]}`;
      }
    }
    return 0;
  }

  dijkstra(mem: Memory, start: Position, goal: Position) {
    const dists = new Map<string, number>();
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

        if (ni < 0 || ni >= this.dim || nj < 0 || nj >= this.dim) {
          continue;
        } else if (mem[ni][nj] === 1) {
          continue;
        }

        if (dist + 1 < (dists.get(nkey) ?? Infinity)) {
          pq.push([dist + 1, [ni, nj], [...path, [ni, nj]]]);
          pq.sort((a, b) => a[0] - b[0]); // A poor man's priority queue...
        }
      }
    }

    return { shortest, visited };
  }

  key(i: number, j: number) {
    return `${i},${j}`;
  }

  unkey(key: string): Position {
    return key.split(",").map(Number) as Position;
  }

  project(bytes: Position[]) {
    let mem = Array.from({ length: this.dim }, () => Array(this.dim).fill(0));
    const futures: Memory[] = [mem];

    bytes.forEach(([i, j]) => {
      mem = mem.map((row) => [...row]);
      mem[i][j] = 1;
      futures.push(mem);
    });

    return futures;
  }

  draw(mem: number[][], visited: Set<string> = new Set()) {
    console.log(
      mem
        .map((row, i) => {
          return row
            .map((cell, j) => {
              const pos = this.key(i, j);
              return visited.has(pos) ? "o" : cell === 1 ? "#" : ".";
            })
            .join("");
        })
        .join("\n"),
    );
  }

  private parse(): Position[] {
    return this.input
      .trim()
      .split("\n")
      .map((line) => {
        const [x, y] = line.split(",").map(Number);
        return [y, x]; // i, j
      });
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/18.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
