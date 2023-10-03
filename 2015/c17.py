from itertools import combinations
from typing import List, Optional


class Solution:
    key = "17"

    def __init__(self, input: str, target: int):
        self.input = input
        self.target = target

    def part_one(self) -> int:
        containers = self.parse()

        for i in range(1, len(containers)):
            if sum(containers[:i]) >= self.target:
                break
        min_containers = i

        # Generate-and-test. There's probably a better algorithm, but :shrug:
        num_valid = 0
        for i in range(min_containers, len(containers)):
            for combo in combinations(containers, i):
                if sum(combo) == self.target:
                    num_valid += 1

        return num_valid

    def part_two(self) -> int:
        containers = self.parse()

        for i in range(1, len(containers)):
            if sum(containers[:i]) >= self.target:
                break
        min_containers = i

        num_valid = 0
        for combo in combinations(containers, min_containers):
            if sum(combo) == self.target:
                num_valid += 1

        return num_valid

    def parse(self) -> List[int]:
        return list(reversed(sorted(int(s) for s in self.input.split("\n"))))


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    target = 150
    print("Part 1:", Solution(input, target).part_one())
    print("Part 2:", Solution(input, target).part_two())
