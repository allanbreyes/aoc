from typing import Optional


class Solution:
    key = "00"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> Optional[str]:
        pass

    def part_two(self) -> Optional[str]:
        pass

    def parse(self):
        pass


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
