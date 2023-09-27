from collections import defaultdict
from typing import Dict, List, Optional, Tuple

MOVES = {
    "^": (-1, 0),
    ">": (0, 1),
    "v": (1, 0),
    "<": (0, -1),
}

Position = Tuple[int, int]


class Solution:
    key = "03"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> int:
        visited: Dict[Position, int] = defaultdict(int)
        pos = (0, 0)
        visited[pos] += 1
        for move in self.parse():
            pos = self.move(pos, move)
            visited[pos] += 1
        return len(visited)

    def part_two(self) -> int:
        visited: Dict[Position, int] = defaultdict(int)
        santa = (0, 0)
        robot = (0, 0)
        visited[santa] += 1
        visited[robot] += 1
        for i, move in enumerate(self.parse()):
            if i % 2 == 0:
                santa = self.move(santa, move)
                visited[santa] += 1
            else:
                robot = self.move(robot, move)
                visited[robot] += 1
        return len(visited)

    def parse(self) -> List[Position]:
        return [MOVES[char] for char in self.input]

    @staticmethod
    def move(pos: Position, move: Position) -> Position:
        return (pos[0] + move[0], pos[1] + move[1])


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
