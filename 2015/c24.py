from functools import reduce
from itertools import combinations
from operator import mul
from typing import Iterable, List, Optional


def qe(packages: Iterable[int]) -> int:
    return reduce(mul, packages, 1)


class Solution:
    key = "24"

    def __init__(self, input: str):
        self.input = input

    def balance(self, packages: List[int], partitions: int) -> int:
        target, rem = divmod(sum(packages), partitions)
        if rem % partitions != 0:
            raise ValueError("can't split evenly")

        for i in range(1, len(packages)):
            qes = [
                qe(combo) for combo in combinations(packages, i) if sum(combo) == target
            ]
            if qes:
                return min(qes)
        return -1

    def part_one(self) -> int:
        return self.balance(self.parse(), 3)

    def part_two(self) -> int:
        return self.balance(self.parse(), 4)

    def parse(self) -> List[int]:
        return [int(line) for line in self.input.split("\n")]


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
