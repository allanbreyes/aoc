import re
from typing import Dict, List, Optional, Tuple


class Solution:
    key = "16"

    def __init__(self, input: str):
        self.input = input
        self.profile = {
            "children": 3,
            "cats": 7,
            "samoyeds": 2,
            "pomeranians": 3,
            "akitas": 0,
            "vizslas": 0,
            "goldfish": 5,
            "trees": 3,
            "cars": 2,
            "perfumes": 1,
        }

    def part_one(self) -> Optional[int]:
        profiles = self.parse()
        for i, profile in self.parse():
            for key, value in profile.items():
                if value != self.profile[key]:
                    break
            else:
                return i
        return None

    def part_two(self) -> Optional[int]:
        for i, profile in self.parse():
            for key, value in profile.items():
                if key in set(["cats", "trees"]):
                    if not value > self.profile[key]:
                        break
                elif key in set(["pomeranians", "goldfish"]):
                    if not value < self.profile[key]:
                        break
                else:
                    if value != self.profile[key]:
                        break
            else:
                return i
        return None

    def parse(self) -> List[Tuple[int, Dict[str, int]]]:
        pat = r"^Sue (\d+): (.*)$"
        result = []
        for line in self.input.split("\n"):
            match = re.search(pat, line)
            if match is None:
                raise ValueError("invalid input")
            i = int(match.group(1))

            # NOTE: it ain't pretty, but it works
            tmp = dict(s.split(": ") for s in match.group(2).split(", "))
            profile = {k: int(s) for k, s in tmp.items()}
            result.append((i, profile))
        return result


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
