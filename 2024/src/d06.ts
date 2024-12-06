import { readFileSync } from "fs";

type Point = [number, number];
type Direction = [number, number];
type Vector = [Point, Direction];

enum Cell {
  Empty = 0,
  Obstacle,
}

const DIRECTIONS: Direction[] = [
  [-1, 0], // ^
  [0, 1], // >
  [1, 0], // v
  [0, -1], // <
];

export class Solver {
  constructor(private input: string) {}

  part1() {
    const { matrix, guard } = this.parse();
    const { loop, path } = this.walk(matrix, guard);
    if (loop) {
      throw new Error("Didn't leave the matrix");
    }

    return this.visited(path).size;
  }

  part2() {
    const { matrix, guard } = this.parse();
    const { path } = this.walk(matrix, guard);
    const visited = this.visited(path);
    visited.delete(this.key(guard[0]));

    let loops = 0;
    visited.forEach((key) => {
      const [i, j] = JSON.parse(key) as Point;
      const world = this.clone(matrix);
      world[i][j] = Cell.Obstacle;

      const { loop } = this.walk(world, guard);
      loops += loop ? 1 : 0;
    });

    return loops;
  }

  clone<T = number[][]>(value: number[][]): T {
    // HACK: this does a deep clone. I didn't want to use lodash or similar.
    return JSON.parse(JSON.stringify(value));
  }

  key(value: Point | Vector) {
    return JSON.stringify(value);
  }

  visited(path: Vector[]) {
    return path.reduce((acc, v) => {
      // NOTE: arrays aren't hashable in sets!
      const [point, _] = v;
      acc.add(this.key(point));
      return acc;
    }, new Set<string>());
  }

  walk(matrix: Cell[][], guard: Vector) {
    guard = this.clone(guard);

    const path: Vector[] = [];
    const states: Set<string> = new Set();
    let loop = false;

    while (true) {
      const [[i, j], [di, dj]] = guard;
      path.push(this.clone(guard));

      // Check for loop
      if (states.has(this.key(guard))) {
        loop = true;
        break;
      }
      states.add(this.key(guard));

      const [ni, nj] = [i + di, j + dj];

      // Handle out of bounds
      if (ni < 0 || ni >= matrix.length || nj < 0 || nj >= matrix[0].length) {
        break;
      }

      // Peek next cell and act
      const next = matrix[ni][nj];
      if (next === Cell.Obstacle) {
        // Turn right
        const idx = DIRECTIONS.findIndex(([x, y]) => x === di && y === dj);
        guard[1] = DIRECTIONS[(idx + 1) % 4];
      } else if (next === Cell.Empty) {
        // Move forward
        guard[0] = [ni, nj];
      } else {
        throw new Error("Unexpected cell");
      }
    }

    return { loop, path };
  }

  private parse() {
    const matrix: Cell[][] = [];
    let guard: Vector = [
      [0, 0],
      [0, 0],
    ];
    this.input
      .trim()
      .split("\n")
      .forEach((line, i) => {
        matrix.push([]);
        line
          .trim()
          .split("")
          .forEach((char: string, j: number) => {
            switch (char) {
              case ".":
                matrix[i][j] = Cell.Empty;
                break;
              case "#":
                matrix[i][j] = Cell.Obstacle;
                break;
              default:
                matrix[i][j] = Cell.Empty;
                const point: Point = [i, j];
                const direction: Direction = {
                  "^": DIRECTIONS[0],
                  ">": DIRECTIONS[1],
                  v: DIRECTIONS[2],
                  "<": DIRECTIONS[3],
                }[char] as Direction;
                guard = [point, direction];
                break;
            }
          });
      });

    return { matrix, guard };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/06.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
