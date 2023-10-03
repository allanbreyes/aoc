from collections import defaultdict
from itertools import permutations
from typing import Dict, Optional
import re
import sys


class Solution:
    key = "13"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        return self.find_best(self.parse())

    def part_two(self) -> int:
        ruleset = self.parse()
        me = "Me"
        subjects = set(ruleset.keys())
        for subject in subjects:
            ruleset[me][subject] = 0
            ruleset[subject][me] = 0

        return self.find_best(ruleset)

    def parse(self) -> Dict[str, Dict[str, int]]:
        ruleset: Dict[str, Dict[str, int]] = defaultdict(lambda: defaultdict(int))
        pattern = (
            r"(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)."
        )
        for line in self.input.split("\n"):
            match = re.search(pattern, line)
            if match is None:
                raise ValueError(f"invalid input: {line}")

            subject = match.group(1)
            change = int(match.group(3))
            neighbor = match.group(4)
            if match.group(2) == "lose":
                change *= -1

            ruleset[subject][neighbor] = change
        return ruleset

    def find_best(self, ruleset: Dict[str, Dict[str, int]]) -> int:
        subjects = ruleset.keys()
        anchor = sorted(subjects)[0]
        num_seats = len(subjects)

        best = -sys.maxsize
        for seating in permutations(subjects):
            if seating[0] != anchor:
                continue

            acc = 0
            for i, subject in enumerate(seating):
                left = seating[i - 1]
                right = seating[(i + 1) % num_seats]
                acc += ruleset[subject][left]
                acc += ruleset[subject][right]
            best = max(best, acc)

        return best


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
