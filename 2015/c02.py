from dataclasses import dataclass
from typing import List


@dataclass
class Box:
    l: int
    w: int
    h: int

    @property
    def surface_area(self) -> int:
        return sum(
            [
                2 * self.l * self.w,
                2 * self.w * self.h,
                2 * self.h * self.l,
            ]
        )

    @property
    def slack(self) -> int:
        return min(
            [
                self.l * self.w,
                self.w * self.h,
                self.h * self.l,
            ]
        )

    @property
    def ribbon(self) -> int:
        # Equal to the shortest perimeter
        x, y, _z = sorted([self.l, self.w, self.h])
        return 2 * (x + y)

    @property
    def volume(self) -> int:
        return self.l * self.w * self.h

    @classmethod
    def from_line(cls, line: str) -> "Box":
        l, w, h, *rest = line.strip().split("x")
        if len(rest) > 0:
            raise ValueError(f"invalid input: {line}")
        return cls(int(l), int(w), int(h))


class Solution:
    key = "02"

    def __init__(self, input: str):
        self.input = input

    def part_one(self):
        return sum(box.surface_area + box.slack for box in self.parse())

    def part_two(self):
        return sum(box.ribbon + box.volume for box in self.parse())

    def parse(self) -> List[Box]:
        return [Box.from_line(line) for line in self.input.strip().split("\n")]


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
