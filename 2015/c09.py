from itertools import permutations
from typing import Dict, Optional, Set, Tuple


class Solution:
    key = "09"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        locations, distances = self.parse()
        return min(self.travel(path, distances) for path in permutations(locations))

    def part_two(self) -> int:
        locations, distances = self.parse()
        return max(self.travel(path, distances) for path in permutations(locations))

    @staticmethod
    def travel(path: Tuple[str, ...], distances: Dict[Tuple[str, str], int]) -> int:
        return sum(distances[(x, y)] for x, y in zip(path, path[1:]))

    def parse(self) -> Tuple[Set[str], Dict[Tuple[str, str], int]]:
        distances: Dict[Tuple[str, str], int] = {}
        locations = set()

        for line in self.input.split("\n"):
            match line.split():
                case (src, "to", dst, "=", distance):
                    distances[(src, dst)] = int(distance)
                    distances[(dst, src)] = int(distance)
                    locations.add(src)
                    locations.add(dst)
                case _:
                    raise ValueError(f"unhandled input: {line}")

        return locations, distances


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
