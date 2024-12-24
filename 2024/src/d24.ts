import { readFileSync } from "fs";

enum Op {
  AND = "AND",
  OR = "OR",
  XOR = "XOR",
}
type Gate = {
  in0: string;
  in1: string;
  op: Op;
  out: string;
};
type Value = 0 | 1 | null;
type Wires = Map<string, Value>;
type Device = {
  wires: Wires;
  gates: Gate[];
};

class ReadError extends Error {}

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    const device = this.parse();
    const wires = this.resolve(device);
    return this.read(wires);
  }

  part2() {
    const device = this.parse();
    const x = this.read(device.wires, "x");
    const y = this.read(device.wires, "y");

    // NOTE: After (quickly) finding out that the swaps weren't brute-forceable,
    // with some hints from an AoC group, I plotted out the circuit with a
    // Python program (not committed) and then manually fixed up the swaps based
    // on deviations from a valid adder program. One Day(TM) I'll write a
    // general solution, but this obviously only works for this specific input.
    const swaps: [string, string][] = [
      ["cbj", "qjj"],
      ["cfk", "z35"],
      ["dmn", "z18"],
      ["gmt", "z07"],
    ];
    this.swap(device.gates, swaps);

    const wires = this.resolve(device);
    const z = this.read(wires, "z");
    if (x + y !== z) throw new Error(`Invalid swap: ${x} + ${y} != ${z}`);

    return swaps.flat().sort().join(",");
  }

  resolve(device: Device): Wires {
    let { wires, gates } = device;
    gates = gates.slice();
    wires = new Map(wires);
    const timeout = gates.length ** 2;

    let t = 0;
    while (gates.length) {
      if (t++ > timeout) {
        throw new Error(`No convergence after ${timeout} iterations`);
      }

      const gate = gates.shift()!;

      const in0 = wires.get(gate.in0) ?? null;
      const in1 = wires.get(gate.in1) ?? null;
      if (in0 === null || in1 === null) {
        gates.push(gate);
        continue;
      } else if (wires.get(gate.out) !== null) {
        throw new Error(`Wire already resolved: ${gate.out}`);
      }

      let result: number;
      switch (gate.op) {
        case Op.AND:
          result = in0 & in1;
          break;
        case Op.OR:
          result = in0 | in1;
          break;
        case Op.XOR:
          result = in0 ^ in1;
          break;
        default:
          throw new Error("Invalid operator");
      }
      if (result !== 0 && result !== 1) {
        throw new Error("Invalid gate result");
      }
      wires.set(gate.out, result);
    }

    return wires;
  }

  read(wires: Wires, prefix = "z") {
    return Array.from(wires.entries())
      .filter(([label, _]) => label.startsWith(prefix))
      .sort(([a], [b]) => a.localeCompare(b))
      .reduce((acc, [_, value], i) => {
        if (value === null) {
          throw new ReadError("Unresolved wire");
        }
        return acc + value * Math.pow(2, i);
      }, 0);
  }

  swap(gates: Gate[], swaps: [string, string][]) {
    for (const [out0, out1] of swaps) {
      const gate0 = gates.find((gate) => gate.out === out0);
      const gate1 = gates.find((gate) => gate.out === out1);
      if (!gate0 || !gate1) {
        throw new Error("Invalid swap");
      }
      gate0.out = out1;
      gate1.out = out0;
    }
    return gates;
  }

  private parse() {
    const wires = new Map<string, Value>();
    const gates: Gate[] = [];

    this.input
      .trim()
      .split("\n\n")
      .forEach((stanza, i) => {
        stanza.split("\n").forEach((line) => {
          if (i === 0) {
            let [label, value] = line.split(": ");
            if (value !== "0" && value !== "1") {
              throw new Error("Invalid wire value");
            }
            wires.set(label, parseInt(value, 10) as Value);
          } else if (i === 1) {
            const [lhs, out] = line.split(" -> ");
            const [in0, op, in1, ...rest] = lhs.split(" ");
            if (rest.length) {
              throw new Error("Invalid gate");
            }
            if (!Object.values(Op).includes(op as Op)) {
              throw new Error("Invalid operator");
            }
            for (const label of [in0, in1, out]) {
              if (!wires.has(label)) wires.set(label, null);
            }
            gates.push({ in0, in1, op: op as Op, out });
          } else {
            throw new Error("Invalid stanza");
          }
        });
      });

    gates.sort((a, b) => {
      return a.out < b.out ? -1 : 1;
    });
    return { wires, gates };
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/24.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
