import { readFileSync } from "fs";

type Tuple = [number, number];
type Axis = string[];
type Grid = Axis[];

const EMPTY = ".";
const WALL = "#";
const BLOCK = "O";
const ROBOT = "@";
const LEFT = "[";
const RIGHT = "]";

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    let { robot, grid, moves } = this.parse("normal");
    for (const move of moves) {
      robot = this.tick(grid, robot, move);
    }

    return this.score(grid);
  }

  part2() {
    let { robot, grid, moves } = this.parse("expanded");
    for (const move of moves) {
      robot = this.tick(grid, robot, move);
    }

    return this.score(grid);
  }

  tick(grid: Grid, robot: Tuple, move: Tuple): Tuple {
    const [ri, rj] = robot;
    const [di, dj] = move;
    const [ni, nj] = [ri + di, rj + dj];

    // Assume grid is always enclosed by walls, so we don't have to do any
    // bounds checking! Return early if we hit a wall or an empty space.
    if (grid[ni][nj] === WALL) {
      return robot;
    } else if (grid[ni][nj] === EMPTY) {
      return [ni, nj];
    }

    const queue = [robot];
    const moved = new Set<string>();

    // Queue up and propagate movement
    while (queue.length > 0) {
      const [i, j] = queue.shift() as Tuple;
      if (moved.has(this.key([i, j]))) {
        continue;
      }

      moved.add(this.key([i, j]));
      const [ii, jj] = [i + di, j + dj];
      if (grid[ii][jj] === WALL) {
        // Fail out if the there's a constraint blocking movement
        return robot;
      } else if (grid[ii][jj] === BLOCK) {
        queue.push([ii, jj]);
      } else if (grid[ii][jj] === LEFT) {
        queue.push([ii, jj], [ii, jj + 1]);
      } else if (grid[ii][jj] === RIGHT) {
        queue.push([ii, jj], [ii, jj - 1]);
      }
    }

    // Make updates
    while (moved.size > 0) {
      for (const key of moved.keys()) {
        const [i, j] = this.unkey(key);
        const [ii, jj] = [i + di, j + dj];
        if (!moved.has(this.key([ii, jj]))) {
          grid[ii][jj] = grid[i][j];
          grid[i][j] = EMPTY;
          moved.delete(this.key([i, j]));
        }
      }
    }

    return [ni, nj];
  }

  key(pos: Tuple) {
    return pos.join(",");
  }

  unkey(key: string) {
    return key.split(",").map(Number) as Tuple;
  }

  draw(grid: Grid, robot: Tuple) {
    grid = grid.map((row) => row.slice());
    grid[robot[0]][robot[1]] = ROBOT;
    return grid.map((row) => row.join("")).join("\n");
  }

  expand(grid: Grid, robot: Tuple) {
    return {
      grid: grid.map((row) => {
        let newRow: Axis = [];
        row.forEach((cell) => {
          if (cell === BLOCK) {
            newRow.push(LEFT, RIGHT);
          } else if (cell === ROBOT) {
            newRow.push(EMPTY, EMPTY);
          } else {
            newRow.push(cell, cell);
          }
        });
        return newRow;
      }),
      robot: [robot[0], robot[1] * 2] as Tuple,
    };
  }

  score(grid: Grid) {
    let sum = 0;
    grid.forEach((row, i) => {
      row.forEach((cell, j) => {
        sum += cell === BLOCK || cell === LEFT ? 100 * i + j : 0;
      });
    });
    return sum;
  }

  private parse(mode: "expanded" | "normal" = "normal") {
    let robot: Tuple = [NaN, NaN];
    let grid: Grid = [];
    let moves: Tuple[] = [];

    this.input
      .trim()
      .split("\n\n")
      .forEach((stanza, s) => {
        if (s === 0) {
          grid = stanza.split("\n").map((line, i) => {
            return line.split("").map((cell, j) => {
              if (cell === ROBOT) {
                robot = [i, j];
                return EMPTY;
              }
              return cell;
            });
          });
        } else if (s === 1) {
          moves = stanza
            .trim()
            .split("")
            .map((char) => {
              switch (char) {
                case "^":
                  return [-1, 0];
                case "v":
                  return [1, 0];
                case "<":
                  return [0, -1];
                case ">":
                  return [0, 1];
              }
            })
            .filter((move) => move !== undefined) as Tuple[];
        } else {
          throw new Error(`unexpected input: ${stanza}`);
        }
      });

    if (mode === "expanded") {
      const { grid: newGrid, robot: newRobot } = this.expand(grid, robot);
      grid = newGrid;
      robot = newRobot;
    }

    return { robot, grid, moves };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/15.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
