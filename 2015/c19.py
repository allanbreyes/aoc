from typing import Dict, Generator, List, Optional, Set, Tuple
import re


class Solution:
    key = "19"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        rules, molecule = self.parse()
        variants = set(self.generate(molecule, rules))
        return len(variants)

    def part_two(self) -> Optional[int]:
        rules, molecule = self.parse()

        irules = {}
        for src, dsts in rules.items():
            for dst in dsts:
                if dst in irules:
                    raise ValueError("uniqueness invariant broken")
                irules[dst] = src

        return self.search(molecule, 0, irules)

    @staticmethod
    def generate(
        molecule: str, rules: Dict[str, Set[str]]
    ) -> Generator[str, None, None]:
        for src, dsts in rules.items():
            for dst in dsts:
                for match in re.finditer(src, molecule):
                    yield molecule[: match.start()] + dst + molecule[match.end() :]

    @staticmethod
    def reverse(molecule: str, irules: Dict[str, str]) -> Set[str]:
        precursors = set()
        for dst, src in irules.items():
            for match in re.finditer(dst, molecule):
                precursors.add(
                    molecule[: match.start()] + src + molecule[match.end() :]
                )
        return precursors

    def search(
        self, s: str, length: int, irules: Dict[str, str], goal: str = "e"
    ) -> int:
        if s == goal:
            return length

        candidates = sorted(self.reverse(s, irules), key=len)

        for candidate in candidates:
            length = self.search(candidate, length + 1, irules)
            if length != -1:
                return length

        return -1

    def parse(self) -> Tuple[Dict[str, Set[str]], str]:
        body, molecule = self.input.split("\n\n")

        lines = body.split("\n")
        rules: Dict[str, Set[str]] = {
            p[0]: set() for line in lines if (p := line.split(" => "))
        }
        for line in lines:
            element, rest = line.split(" => ")
            rules[element].add(rest)

        return rules, molecule


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
