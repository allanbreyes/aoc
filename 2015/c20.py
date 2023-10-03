from typing import Optional
import numpy as np


class Solution:
    key = "20"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        target = self.parse()

        # Brute force lol
        houses = np.zeros(target // 10, dtype=int)  # Guess a smaller bound
        for elf in range(1, len(houses)):
            for i in range(elf, len(houses), elf):
                houses[i] += elf * 10

        for i, house in enumerate(houses):
            if house >= target:
                return i

        return -1

    def part_two(self) -> int:
        target = self.parse()

        # Brute force again lol
        houses = np.zeros(target // 10, dtype=int)  # Guess a smaller bound
        for elf in range(1, len(houses)):
            n = 0
            for i in range(elf, len(houses), elf):
                if n >= 50:
                    break

                houses[i] += elf * 11
                n += 1

        for i, house in enumerate(houses):
            if house >= target:
                return i

        return -1

    def parse(self):
        return int(self.input)


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
