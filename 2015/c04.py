from typing import Optional
import hashlib


class Solution:
    key = "04"

    def __init__(self, input: str):
        self.secret = input

    def part_one(self) -> Optional[int]:
        for i in range(10**9):
            h = self.hash(i)
            if h.startswith("0" * 5):
                return i
        return None

    def part_two(self) -> Optional[int]:
        for i in range(10**9):
            h = self.hash(i)
            if h.startswith("0" * 6):
                return i
        return None

    def hash(self, num: int) -> str:
        h = hashlib.new("md5")
        h.update(f"{self.secret}{num}".encode())
        return h.hexdigest()


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
