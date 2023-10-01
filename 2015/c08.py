import re
from typing import List, Optional


class Solution:
    key = "08"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        raw = 0
        dec = 0
        for line in self.parse():
            raw += len(line)
            dec += len(eval(line))  # HACK: unsafe! But it works.
        return raw - dec

    def part_two(self) -> int:
        raw = 0
        enc = 0
        lines: List[str] = []
        for line in self.parse():
            raw += len(line)
            line = re.sub(r"\\", r"\\\\", line)
            line = re.sub(r'"', r'\\"', line)
            line = f'"{line}"'
            enc += len(line)
        return enc - raw

    def parse(self):
        return self.input.split("\n")


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
