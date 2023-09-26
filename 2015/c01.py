from typing import Optional


class Solution:
    key = "01"

    def __init__(self, input: str):
        self.input = input

    def part_one(self):
        floor = 0
        for char in self.input.strip():
            match char:
                case "(":
                    floor += 1
                case ")":
                    floor -= 1
                case _:
                    raise ValueError("unrecognized character")
        return floor


    def part_two(self):
        floor = 0
        for i, char in enumerate(self.input.strip()):
            match char:
                case "(":
                    floor += 1
                case ")":
                    floor -= 1
                case _:
                    raise ValueError("unrecognized character")
            if floor < 0:
                return i + 1


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
