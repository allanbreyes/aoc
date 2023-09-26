from typing import Optional


class Solution:
    key = "01"

    def __init__(self, input: Optional[str] = None):
        if input is None:
            with open(f"./inputs/{self.key}", "r") as fh:
                self.input = fh.read()
        else:
            self.input = input

    def part_one(self):
        pass

    def part_two(self):
        pass
