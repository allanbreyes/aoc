from dataclasses import astuple, dataclass
from functools import reduce
from math import floor
from operator import mul
from typing import Dict, Generator, List, Optional, Tuple
import re


@dataclass
class Properties:
    capacity: int = 0
    durability: int = 0
    flavor: int = 0
    texture: int = 0
    calories: int = 0

    def __add__(self, other: "Properties") -> "Properties":
        return Properties(*[x + y for x, y in zip(astuple(self), astuple(other))])

    def __mul__(self, n: int) -> "Properties":
        return self.mul(n)

    def mul(self, n: int) -> "Properties":
        return Properties(*[p * n for p in astuple(self)])

    @property
    def score(self) -> int:
        return reduce(mul, [max(0, p) for p in astuple(self)[:-1]])


def generate(
    n: int,
    total: int,
    curr: Optional[List[int]] = None,
) -> Generator[Tuple[int, ...], None, None]:
    if curr is None:
        curr = []
    if n == 0:
        if sum(curr) == total:
            yield tuple(curr)
        return
    for value in range(total + 1):
        if sum(curr) + value <= total:
            yield from generate(n - 1, total, curr + [value])


class Solution:
    key = "15"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        return self.find_best(self.parse())

    def part_two(self) -> int:
        return self.find_best(self.parse(), calories=500)

    def find_best(
        self,
        ingredients: Dict[str, Properties],
        calories: Optional[int] = None,
    ) -> int:
        # TODO: Use an actual optimization algorithm
        best = 0
        names = list(ingredients.keys())
        for combo in generate(len(ingredients), 100):
            properties = Properties()
            recipe = dict(zip(names, combo))
            for name, count in recipe.items():
                properties += ingredients[name].mul(count)
            if calories is not None and properties.calories != calories:
                continue
            best = max(best, properties.score)
        return best

    def parse(self) -> Dict[str, Properties]:
        result: Dict[str, Properties] = {}
        pat = r"(\w+): capacity ([-\d]+), durability ([-\d]+), flavor ([-\d]+), texture ([-\d]+), calories ([-\d]+)"
        for line in self.input.split("\n"):
            match = re.search(pat, line)
            if match is None:
                raise ValueError(f"inhandled input: {line}")
            name, *rest = match.groups()
            result[name] = Properties(*[int(s) for s in rest])
        return result


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
