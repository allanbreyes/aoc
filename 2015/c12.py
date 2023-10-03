from typing import Any, Optional
import json


class Solution:
    key = "12"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        data = self.parse()
        return self.traverse(data)

    def part_two(self) -> int:
        data = self.parse()
        return self.traverse(data, True)

    def parse(self):
        return json.loads(self.input)

    def traverse(self, data: Any, drop_red=False) -> int:
        acc = 0

        if isinstance(data, dict):
            if drop_red and "red" in data.values():
                return acc

            for key in data:
                acc += self.traverse(data[key], drop_red)
        elif isinstance(data, list):
            for item in data:
                acc += self.traverse(item, drop_red)
        elif isinstance(data, int):
            acc += data

        return acc


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
