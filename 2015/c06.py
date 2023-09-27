from dataclasses import dataclass
from enum import auto, Enum
from typing import Any, Generator, Iterable, Optional, NamedTuple, Tuple
import numpy as np
import numpy.typing as NP


class Point(NamedTuple):
    row: int
    col: int

    @classmethod
    def from_string(cls, s: str) -> "Point":
        x, y, *rest = s.split(",")
        if len(rest) > 0:
            raise ValueError(f"extra fields: {rest}")
        return cls(int(x), int(y))


class Operation(Enum):
    ON = auto()
    OFF = auto()
    TOGGLE = auto()

    @classmethod
    def on_or_off(cls, s: str) -> "Operation":
        return {"on": Operation.ON, "off": Operation.OFF}[s]


@dataclass
class Instruction:
    op: Operation
    c0: Point
    c1: Point

    def apply(self, grid: NP.NDArray[np.int_], part: int):
        x0, y0 = self.c0
        x1, y1 = self.c1
        subgrid = grid[x0 : x1 + 1, y0 : y1 + 1]
        match (part, self.op):
            case (1, Operation.ON):
                subgrid[:] = 1
            case (1, Operation.OFF):
                subgrid[:] = 0
            case (1, Operation.TOGGLE):
                subgrid ^= 1
            case (2, Operation.ON):
                subgrid += 1
            case (2, Operation.OFF):
                rows, cols = subgrid.shape
                for i in range(rows):
                    for j in range(cols):
                        p = (i, j)
                        if subgrid[p] > 0:
                            subgrid[p] -= 1
            case (2, Operation.TOGGLE):
                subgrid += 2
            case _:
                raise ValueError(f"unhandled input: {(part, self.op)}")


class Solution:
    key = "06"

    def __init__(self, input: str, shape: Tuple = (1000, 1000)):
        self.input = input
        self.shape = shape

    def part_one(self) -> Any:
        grid = np.zeros(self.shape, dtype=int)
        for ins in self.parse():
            ins.apply(grid, 1)
        return np.sum(grid)

    def part_two(self) -> Optional[str]:
        grid = np.zeros(self.shape, dtype=int)
        for ins in self.parse():
            ins.apply(grid, 2)
        return np.sum(grid)

    def parse(self) -> Generator[Instruction, None, None]:
        for line in self.input.split("\n"):
            match line.split():
                case ["turn", on_or_off, c0, _, c1]:
                    yield Instruction(
                        Operation.on_or_off(on_or_off),
                        Point.from_string(c0),
                        Point.from_string(c1),
                    )
                case ["toggle", c0, _, c1]:
                    yield Instruction(
                        Operation.TOGGLE,
                        Point.from_string(c0),
                        Point.from_string(c1),
                    )
                case _:
                    raise ValueError(f"unhandled input: {line}")


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
