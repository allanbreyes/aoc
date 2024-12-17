import { readFileSync } from "fs";

type Registers = Map<string, number>;

export class Solver {
  program: number[] = [];
  registers: Map<string, number> = new Map();
  ip: number = 0;

  constructor(private readonly input: string) {}

  part1() {
    this.init();
    return this.runAll().join(",");
  }

  part2() {
    return 0;
  }

  clear() {
    this.registers.clear();
    this.program = [];
    this.ip = 0;
  }

  init() {
    const [registers, program] = this.parse();
    this.registers = registers;
    this.program = program;
    this.ip = 0;
  }

  *run() {
    while (this.ip < this.program.length) {
      const opcode = this.program[this.ip];
      const operand = this.program[this.ip + 1];
      // console.log({ ip: this.ip, opcode, operand, reg: this.registers });
      let jumped = false;
      switch (opcode) {
        case 0:
          this.adv0(operand);
          break;
        case 1:
          this.bxl1(operand);
          break;
        case 2:
          this.bst2(operand);
          break;
        case 3:
          this.ip += this.jnz3(operand);
          jumped = true;
          break;
        case 4:
          this.bxc4(operand);
          break;
        case 5:
          yield this.out5(operand);
          break;
        case 6:
          this.bdv6(operand);
          break;
        case 7:
          this.cdv7(operand);
          break;
        default:
          throw new Error("invalid opcode");
      }
      if (!jumped) {
        this.ip += 2;
      }
    }
  }

  runAll() {
    return Array.from(this.run());
  }

  combo(operand: number) {
    /**
     * Combo operands 0 through 3 represent literal values 0 through 3.
     * Combo operand 4 represents the value of register A.
     * Combo operand 5 represents the value of register B.
     * Combo operand 6 represents the value of register C.
     * Combo operand 7 is reserved and will not appear in valid programs.
     */
    switch (operand) {
      case 0:
      case 1:
      case 2:
      case 3:
        return operand;
      case 4:
        return this.registers.get("A")!;
      case 5:
        return this.registers.get("B")!;
      case 6:
        return this.registers.get("C")!;
      case 7:
        throw new Error("reserved");
      default:
        throw new Error("invalid combo operand");
    }
  }

  adv0(combo: number) {
    /**
     * The adv instruction (opcode 0) performs division. The numerator is the
     * value in the A register. The denominator is found by raising 2 to the
     * power of the instruction's combo operand. (So, an operand of 2 would
     * divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result
     * of the division operation is truncated to an integer and then written to
     * the A register.
     */
    const value = Math.floor(this.registers.get("A")! / 2 ** this.combo(combo));
    this.registers.set("A", value);
    return value;
  }

  bxl1(operand: number) {
    /**
     * The bxl instruction (opcode 1) calculates the bitwise XOR of register B
     * and the instruction's literal operand, then stores the result in register
     * B.
     */
    const value = this.registers.get("B")! ^ operand;
    this.registers.set("B", value);
    return value;
  }

  bst2(combo: number) {
    /**
     * The bst instruction (opcode 2) calculates the value of its combo operand
     * modulo 8 (thereby keeping only its lowest 3 bits), then writes that value
     * to the B register.
     */
    const value = this.combo(combo) % 8;
    this.registers.set("B", value);
    return value;
  }

  jnz3(operand: number) {
    /**
     * The jnz instruction (opcode 3) does nothing if the A register is 0.
     * However, if the A register is not zero, it jumps by setting the
     * instruction pointer to the value of its literal operand; if this
     * instruction jumps, the instruction pointer is not increased by 2 after
     * this instruction.
     */
    if (this.registers.get("A") !== 0) {
      return operand - this.ip;
    }
    return 2;
  }

  bxc4(_operand: number) {
    /**
     * The bxc instruction (opcode 4) calculates the bitwise XOR of register B
     * and register C, then stores the result in register B. (For legacy
     * reasons, this instruction reads an operand but ignores it.)
     */
    const value = this.registers.get("B")! ^ this.registers.get("C")!;
    this.registers.set("B", value);
    return value;
  }

  out5(combo: number) {
    /**
     * The out instruction (opcode 5) calculates the value of its combo operand
     * modulo 8, then outputs that value. (If a program outputs multiple values,
     * they are separated by commas.)
     */
    const value = this.combo(combo) % 8;
    return value;
  }

  bdv6(combo: number) {
    /**
     * The bdv instruction (opcode 6) works exactly like the adv instruction
     * except that the result is stored in the B register. (The numerator is
     * still read from the A register.)
     */
    const value = Math.floor(this.registers.get("A")! / 2 ** this.combo(combo));
    this.registers.set("B", value);
    return value;
  }

  cdv7(combo: number) {
    /**
     * The cdv instruction (opcode 7) works exactly like the adv instruction
     * except that the result is stored in the C register. (The numerator is
     * still read from the A register.)
     */
    const value = Math.floor(this.registers.get("A")! / 2 ** this.combo(combo));
    this.registers.set("C", value);
    return value;
  }

  private parse() {
    return this.input
      .trim()
      .split("\n\n")
      .map((stanza, i) => {
        if (i === 0) {
          return stanza.split("\n").reduce((acc, line) => {
            const [_, reg, n] = line.match(/Register (\w+): (\d+)/)!;
            acc.set(reg, parseInt(n, 10));
            return acc;
          }, new Map<string, number>());
        } else if (i === 1) {
          const matches = stanza.matchAll(/(\d+)/g);
          return Array.from(matches).map(([, n]) => parseInt(n, 10));
        } else {
          throw new Error("unexpected stanza");
        }
      }) as [Registers, number[]];
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/17.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
