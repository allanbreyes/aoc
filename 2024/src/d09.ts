import { readFileSync } from "fs";

type DiskInfo = [number, number];

export class Solver {
  constructor(private input: string) {}

  part1() {
    const array = this.expand(this.parse());

    let i = 0;
    let j = array.length - 1;

    while (i < j) {
      const used = array[j].filter((value) => value !== ".").length;
      const free = array[i].filter((value) => value === ".").length;
      const delta = Math.min(free, used);

      let moved = 0;
      array[j].forEach((value: number | string, k: number) => {
        if (moved < delta && value !== ".") {
          array[j][k] = ".";
          moved += 1;
        }
      });
      array[j].sort().reverse(); // Shift data to the left of the disk
      array[i].forEach((value: number | string, k: number) => {
        if (moved > 0 && value === ".") {
          array[i][k] = j;
          moved -= 1;
        }
      });

      if (array[i].filter((value) => value === ".").length === 0) {
        i++;
      }

      if (array[j].filter((value) => value !== ".").length === 0) {
        j--;
      }
    }

    return this.checksum(array);
  }

  part2() {
    const array = this.expand(this.parse());

    let j = array.length - 1;
    while (j > 0) {
      const used = array[j].filter((value) => value === j).length;

      for (let i = 0; i < j; i++) {
        const free = array[i].filter((value) => value === ".").length;

        if (used > free) {
          continue;
        }

        let moved = 0;
        array[j].forEach((value: number | string, k: number) => {
          if (value === j) {
            array[j][k] = ".";
            moved += 1;
          }
        });
        array[i].forEach((value: number | string, k: number) => {
          if (moved > 0 && value === ".") {
            array[i][k] = j;
            moved -= 1;
          }
        });

        break;
      }
      j--;
    }

    return this.checksum(array);
  }

  draw(array: Array<number | string>[]) {
    return this.flatten(array).join("");
  }

  private checksum(array: Array<number | string>[]) {
    let result = 0;
    this.flatten(array).forEach((value, i) => {
      if (typeof value === "string") return;
      result += i * value;
    });
    return result;
  }

  private expand(disks: DiskInfo[]) {
    let array: Array<number | string>[] = [];
    disks.forEach(([used, free], i) => {
      array[i] = [];

      for (let j = 0; j < used; j++) {
        array[i].push(i);
      }
      for (let j = 0; j < free; j++) {
        array[i].push(".");
      }
    });
    return array;
  }

  private flatten(array: Array<number | string>[]) {
    return array.flatMap((value) => {
      if (typeof value === "string") return value;
      return value;
    });
  }

  private parse() {
    const disks: DiskInfo[] = [];
    const digits = this.input.trim().split("").map(Number);
    for (let i = 0; i < digits.length; i += 2) {
      disks.push([digits[i], digits[i + 1] ?? 0]);
    }
    return disks;
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/09.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
