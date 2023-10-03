from dataclasses import dataclass
from typing import List, Optional
import re


@dataclass
class Reindeer:
    name: str
    speed: int
    duration: int
    rest: int

    # Stateful properties
    dist: int = 0
    points: int = 0
    flying: bool = True
    t_flying: int = 0
    t_resting: int = 0

    def simulate(self, t: int = 0) -> int:
        dist = 0
        flying = True
        while t > 0:
            if flying:
                dt = min(t, self.duration)
                dist += dt * self.speed
                flying = False
            else:
                dt = min(t, self.rest)
                flying = True
            t -= dt
        return dist

    def tick(self):
        if self.flying:
            self.dist += self.speed
            self.t_flying += 1
            if self.t_flying >= self.duration:
                self.t_flying = 0
                self.flying = False
        else:
            self.t_resting += 1
            if self.t_resting >= self.rest:
                self.t_resting = 0
                self.flying = True


class Solution:
    key = "14"

    def __init__(self, input: str, t: int):
        self.input = input
        self.t = t

    def part_one(self) -> int:
        return max(subject.simulate(self.t) for subject in self.parse())

    def part_two(self) -> int:
        subjects = self.parse()
        for i in range(self.t):
            lead = 0
            for subject in subjects:
                subject.tick()
                lead = max(lead, subject.dist)

            for subject in subjects:
                if subject.dist >= lead:
                    subject.points += 1

        return max(subject.points for subject in subjects)

    def parse(self) -> List[Reindeer]:
        subjects = []
        pattern = r"(\w+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds."
        for line in self.input.split("\n"):
            match = re.search(pattern, line)
            if match is None:
                raise ValueError(f"invalid input: {line}")

            name = match.group(1)
            speed = int(match.group(2))
            duration = int(match.group(3))
            rest = int(match.group(4))

            subjects.append(Reindeer(name, speed, duration, rest))

        return subjects


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    t = 2503
    print("Part 1:", Solution(input, t).part_one())
    print("Part 2:", Solution(input, t).part_two())
