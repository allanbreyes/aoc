import { readFileSync } from "fs";

type Tuple = [number, number];
type Robot = [Tuple, Tuple];

export class Solver {
  shape: Tuple;

  constructor(
    private readonly input: string,
    shape: Tuple = [101, 103],
  ) {
    this.shape = shape;
  }

  part1() {
    const robots = this.tick(this.parse(), 100);
    return this.score(robots);
  }

  part2() {
    let robots = this.parse();
    for (let t = 1; t < 10_000; t++) {
      robots = this.tick(robots, 1);

      const heuristic = this.heuristic(robots);
      // Parameters were tuned after some trial and error
      if (heuristic > 1_000) {
        const drawing = this.draw(robots);
        // Draw the tree!
        console.log(
          drawing
            .split("\n")
            .slice(24, 57)
            .map((line) => {
              return line.slice(38, 69);
            })
            .join("\n"),
        );
        return t;
      }
    }
  }

  tick(robots: Robot[], t: number = 0): Robot[] {
    if (t === 0) {
      return robots;
    }

    const next = robots.map((robot, i) => {
      let [[x, y], [vx, vy]] = robot;

      let [nx, ny] = [x + vx, y + vy];
      nx = nx < 0 ? this.shape[0] + nx : nx % this.shape[0];
      ny = ny < 0 ? this.shape[1] + ny : ny % this.shape[1];

      return [
        [nx, ny],
        [vx, vy],
      ] as Robot;
    });

    return this.tick(next, t - 1);
  }

  score(robots: Robot[]): number {
    const [sx, sy] = this.shape.map((n) => Math.floor(n / 2));
    const quadrants = [0, 0, 0, 0]; // [NW, NE, SE, SW]
    robots.forEach(([[x, y], _]) => {
      if (x < sx && y < sy) {
        quadrants[0]++;
      } else if (x > sx && y < sy) {
        quadrants[1]++;
      } else if (x > sx && y > sy) {
        quadrants[2]++;
      } else if (x < sx && y > sy) {
        quadrants[3]++;
      }
    });

    return quadrants.reduce((acc, n) => acc * n, 1);
  }

  draw(robots: Robot[]): string {
    const grid = Array.from({ length: this.shape[1] }, () =>
      Array.from({ length: this.shape[0] }, () => " "),
    );

    robots.forEach(([[x, y], _]) => {
      grid[y][x] = "#";
    });

    return grid.map((row) => row.join("")).join("\n");
  }

  heuristic(robots: Robot[]): number {
    // Based on the number of adjacent robots
    const positions: Set<string> = robots.reduce((acc, [[x, y], _]) => {
      acc.add(`${x},${y}`);
      return acc;
    }, new Set<string>());

    let heuristic = 0;
    robots.forEach(([[x, y], _]) => {
      [-1, 0, 1].forEach((dx) => {
        [-1, 0, 1].forEach((dy) => {
          if (dx === 0 && dy === 0) {
            return;
          }
          if (positions.has(`${x + dx},${y + dy}`)) {
            heuristic++;
          }
        });
      });
    });

    return heuristic;
  }

  private parse(): Robot[] {
    return this.input
      .trim()
      .split("\n")
      .map((line) => {
        const matches = line.match(/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/);
        if (!matches) {
          throw new Error(`Invalid input: ${line}`);
        }
        return [
          [+matches[1], +matches[2]],
          [+matches[3], +matches[4]],
        ];
      });
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/14.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
