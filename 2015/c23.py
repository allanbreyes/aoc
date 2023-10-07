from collections import defaultdict, namedtuple
from typing import Dict, List, Optional


# Opcodes/instructions
def hlf(state: Dict[str, int], r: str) -> int:
    state[r] //= 2
    return 1


def tpl(state: Dict[str, int], r: str) -> int:
    state[r] *= 3
    return 1


def inc(state: Dict[str, int], r: str) -> int:
    state[r] += 1
    return 1


def jmp(state: Dict[str, int], o: int) -> int:
    return o


def jie(state: Dict[str, int], r: str, o: int) -> int:
    return o if state[r] % 2 == 0 else 1


def jio(state: Dict[str, int], r: str, o: int) -> int:
    return o if state[r] == 1 else 1


Instruction = namedtuple("Instruction", ["op", "args"])


class Solution:
    key = "23"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> Dict[str, int]:
        instructions = self.parse()
        pc = 0
        state: Dict[str, int] = defaultdict(int)
        while -1 < pc < len(instructions):
            op, args = instructions[pc]
            pc += op(state, *args)

        return dict(state)

    def part_two(self) -> Dict[str, int]:
        instructions = self.parse()
        pc = 0
        state: Dict[str, int] = defaultdict(int)
        state["a"] = 1
        while -1 < pc < len(instructions):
            op, args = instructions[pc]
            pc += op(state, *args)

        return dict(state)

    def parse(self) -> List[Instruction]:
        instructions: List[Instruction] = []
        for line in self.input.split("\n"):
            match line.split():
                case ["hlf", r]:
                    instructions.append(Instruction(hlf, (r,)))
                case ["tpl", r]:
                    instructions.append(Instruction(tpl, (r,)))
                case ["inc", r]:
                    instructions.append(Instruction(inc, (r,)))
                case ["jmp", o]:
                    instructions.append(Instruction(jmp, (int(o),)))
                case ["jie", r, o]:
                    r, *_ = r.split(",")
                    instructions.append(Instruction(jie, (r, int(o))))
                case ["jio", r, o]:
                    r, *_ = r.split(",")
                    instructions.append(Instruction(jio, (r, int(o))))
                case _:
                    raise ValueError("unhandled input")
        return instructions


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
