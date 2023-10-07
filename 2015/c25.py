from typing import Generator, Optional, Tuple
import numpy as np
import re


class Solution:
    key = "25"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> Optional[int]:
        target = self.parse()

        # For debugging only; not really needed
        n = sum(target)
        grid = np.zeros((n, n), dtype=int)

        code = None
        for coord in self.generate():
            if code is None:
                code = self.next()
            else:
                code = self.next(code)

            grid[(coord[0] - 1, coord[1] - 1)] = code

            if coord == target:
                break

        print(grid)
        return code

    def generate(self) -> Generator[Tuple[int, int], None, None]:
        row, col = (1, 1)
        yield row, col

        maxrow = row
        while True:
            if row == 1:
                row = maxrow + 1
                maxrow = row
                col = 1
            else:
                row -= 1
                col += 1
            yield row, col

    def next(self, code: Optional[int] = None) -> int:
        if code is None:
            return 20151125
        return code * 252533 % 33554393

    def parse(self) -> Tuple[int, int]:
        pat = r".*row (\d+), column (\d+)\."
        match = re.search(pat, self.input)
        if not match:
            raise ValueError(f"no match for: {self.input}")
        return int(match.group(1)), int(match.group(2))


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
