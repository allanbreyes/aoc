from typing import Optional
import numpy as np
import numpy.typing as NP


class Solution:
    key = "18"

    def __init__(self, input: str, n: int = 100, max_t: int = 100):
        self.input = input
        self.n = n
        self.shape = (n, n)
        self.max_t = max_t
        self.corners = set([(0, 0), (0, n - 1), (n - 1, 0), (n - 1, n - 1)])

    def part_one(self) -> int:
        state = self.parse()
        for t in range(self.max_t):
            state = self.simulate(state)
        return np.sum(state, dtype=int)

    def part_two(self) -> int:
        state = self.parse()
        for corner in self.corners:
            state[corner] = 1

        for t in range(self.max_t):
            state = self.simulate(state, freeze=True)
        return np.sum(state, dtype=int)

    def simulate(
        self, state: NP.NDArray[np.int_], freeze: bool = False
    ) -> NP.NDArray[np.int_]:
        new = np.zeros(self.shape, dtype=int)

        for (i, j), value in np.ndenumerate(state):
            if freeze and (i, j) in self.corners:
                new[i, j] = 1
                continue

            # TODO: there's probably a numpy thing for this...
            neighbors = [
                state[m, n]
                for m, n in [
                    (i - 1, j),
                    (i - 1, j + 1),
                    (i, j + 1),
                    (i + 1, j + 1),
                    (i + 1, j),
                    (i + 1, j - 1),
                    (i, j - 1),
                    (i - 1, j - 1),
                ]
                if 0 <= m < self.n and 0 <= n < self.n
            ]

            on = sum(neighbors)

            if value == 1:
                new[i, j] = 1 if 2 <= on <= 3 else 0
            else:
                new[i, j] = 1 if on == 3 else 0
        return new

    def parse(self) -> NP.NDArray[np.int_]:
        grid = np.zeros(self.shape, dtype=int)
        for i, line in enumerate(self.input.split("\n")):
            for j, value in enumerate(line):
                match value:
                    case "#":
                        grid[i, j] = 1
                    case ".":
                        grid[i, j] = 0
                    case _:
                        raise ValueError(f"unhandled input: {value}")
        return grid


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
