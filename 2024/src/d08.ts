import { readFileSync } from "fs";

export class Solver {
  constructor(private input: string) {}

  part1() {
    const { nodes, grid } = this.parse();
    return this.countAllAntinodes(nodes, grid, true);
  }

  part2() {
    const { nodes, grid } = this.parse();
    return this.countAllAntinodes(nodes, grid, false);
  }

  key(value: number[]) {
    return JSON.stringify(value);
  }

  countAllAntinodes(
    nodes: Map<string, number[][]>,
    grid: string[][],
    once = true,
  ) {
    const antinodes = new Set<string>();

    nodes.forEach((locations) => {
      this.findAntinodes(locations, grid, once).forEach((key) => {
        antinodes.add(key);
      });
    });

    return antinodes.size;
  }

  findAntinodes(locations: number[][], grid: string[][], once = true) {
    const antinodes = new Set<string>();

    locations.forEach(([i, j], k) => {
      locations.slice(k + 1).forEach(([m, n]) => {
        const [di, dj] = [m - i, n - j];

        if (!once) {
          antinodes.add(this.key([i, j]));
          antinodes.add(this.key([m, n]));
        }

        this.project([i, j], [-di, -dj], grid, once).forEach((point) => {
          antinodes.add(point);
        });

        this.project([m, n], [di, dj], grid, once).forEach((point) => {
          antinodes.add(point);
        });
      });
    });

    return antinodes;
  }

  project(start: number[], delta: number[], grid: string[][], once = false) {
    const [iMax, jMax] = [grid.length, grid[0].length];
    const path = new Set<string>();
    let [i, j] = start;

    while (i >= 0 && i < iMax && j >= 0 && j < jMax) {
      i += delta[0];
      j += delta[1];

      if (i < 0 || i >= iMax || j < 0 || j >= jMax) {
        break;
      }

      path.add(this.key([i, j]));

      if (once) {
        break;
      }
    }

    return path;
  }

  private parse() {
    const nodes = new Map<string, number[][]>();
    const grid: string[][] = [];
    this.input
      .trim()
      .split("\n")
      .forEach((line, i) => {
        grid.push([]);
        return line.split("").forEach((char, j) => {
          if (char.match(/[A-Za-z0-9]/)) {
            nodes.get(char) || nodes.set(char, []);
            nodes.get(char)?.push([i, j]);
          }
          grid[i].push(char);
        });
      });

    return { nodes, grid };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/08.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
