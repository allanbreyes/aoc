from typing import List, Optional


class Solution:
    key = "10"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        numstr = self.input
        for _ in range(40):
            numstr = self.say(numstr)
        return len(numstr)

    def part_two(self) -> int:
        numstr = self.input
        for _ in range(50):
            numstr = self.say(numstr)
        return len(numstr)

    @staticmethod
    def say(numstr: str) -> str:
        digit = ""
        times = 0

        buffer: List[str] = []
        for char in numstr:
            if digit == "":
                digit = char

            if char != digit:
                buffer.append(f"{times}{digit}")
                digit = char
                times = 0

            times += 1
        else:
            buffer.append(f"{times}{digit}")

        return "".join(buffer)


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
