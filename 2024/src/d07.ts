import { readFileSync } from "fs";

const OP = {
  add: (a: number, b: number) => a + b,
  mul: (a: number, b: number) => a * b,
  concat: (a: number, b: number) => +`${a}${b}`,
};

function* permute<T>(elements: T[], n: number): Generator<T[]> {
  if (n === 1) {
    for (const element of elements) {
      yield [element];
    }
  } else {
    for (const element of elements) {
      for (const rest of permute(elements, n - 1)) {
        yield [element, ...rest];
      }
    }
  }
}

export class Solver {
  constructor(private input: string) {}

  part1() {
    return this.parse().reduce((sum, { result, operands }) => {
      const generator = permute([OP.add, OP.mul], operands.length - 1);
      return sum + (this.test(operands, generator, result) ? result : 0);
    }, 0);
  }

  part2() {
    return this.parse().reduce((sum, { result, operands }) => {
      const generator = permute(Object.values(OP), operands.length - 1);
      return sum + (this.test(operands, generator, result) ? result : 0);
    }, 0);
  }

  test(operands: number[], generator: Generator<Function[]>, result: number) {
    for (const ops of generator) {
      // NOTE: we could fast-out here if the intermediate value is greater than
      // the result, but I left this generalized in case future problems have
      // operations that produce non-monotonically increasing results.
      const value = ops.reduce((acc, op, i) => {
        return op(acc, operands[i + 1]);
      }, operands[0]);

      if (value === result) {
        return true;
      }
    }
    return false;
  }

  private parse() {
    return this.input
      .trim()
      .split("\n")
      .map((line) => {
        let [result, ...operands] = line.split(/:?\s/).map((x) => +x);
        return { result, operands };
      });
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/07.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
