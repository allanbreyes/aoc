from collections import defaultdict
from typing import Dict, List, Optional


class Solution:
    key = "05"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        return sum(self.is_nice(s) for s in self.input.split("\n"))

    def part_two(self) -> int:
        return sum(self.is_nice2(s) for s in self.input.split("\n"))

    @staticmethod
    def is_nice(s: str) -> bool:
        num_vowels = 0
        dual_chars = False

        bad_pairs = {"ab", "cd", "pq", "xy"}
        vowels = {"a", "e", "i", "o", "u"}

        for i in range(len(s) - 1):
            a, b = s[i], s[i + 1]
            ab = a + b

            if i == 0 and a in vowels:
                num_vowels += 1

            if b in vowels:
                num_vowels += 1

            if not dual_chars and a == b:
                dual_chars = True

            if ab in bad_pairs:
                return False

        return num_vowels >= 3 and dual_chars

    @staticmethod
    def is_nice2(s: str) -> bool:
        pairs: Dict[str, List[int]] = defaultdict(list)
        has_pairs = False
        has_triad = False

        s += "!"  # HACK: just add another character at the end

        for i in range(len(s) - 2):
            a, b, c = s[i], s[i + 1], s[i + 2]
            ab = a + b
            abc = ab + c

            pairs[ab].append(i)  # It's sorted \o/

            if not has_triad and a == c:
                has_triad = True

        for pair, indexes in pairs.items():
            if len(indexes) < 2:
                continue

            if indexes[-1] - indexes[0] >= 2:  # Greedy
                has_pairs = True
                break

        return has_pairs and has_triad


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
