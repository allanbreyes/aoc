from string import ascii_lowercase
from typing import List, Optional


class Password:
    itoa = dict(enumerate(ascii_lowercase))
    atoi = {v: k for k, v in itoa.items()}

    badchars = set("iol")
    base = len(itoa)

    def __init__(self, s: str):
        self.value = tuple(self.atoi[c] for c in s)

    def __str__(self) -> str:
        return "".join(self.itoa[n] for n in self.value)

    def is_valid(self) -> bool:
        tmp = tuple(list(self.value) + [-1, -2])  # HACK: extend with 2 dummies
        has_straight = False
        has_badchars = False
        pair_indexes = set()

        # Rule 0: 8 characters
        if len(self.value) != 8:
            return False

        for i in range(len(self.value)):
            n = tmp[i]

            # Rule 1: one increasing triad
            if not has_straight:
                lo, mid, hi = tmp[i : i + 3]
                if hi - mid == mid - lo == 1:
                    has_straight = True

            # Rule 2: no bad chars (return early)
            if self.itoa[n] in self.badchars:
                return False

            # Rule 3: >=2 non-overlapping pairs
            if i not in pair_indexes and i + 1 not in pair_indexes:
                lo, hi = tmp[i : i + 2]
                if lo == hi:
                    pair_indexes.add(i)
                    pair_indexes.add(i + 1)

        return has_straight and len(pair_indexes) >= 4

    def next_valid(self) -> Optional["Password"]:
        length = len(self.value)
        candidate = self
        while length <= 8:
            candidate = candidate.next()
            length = len(candidate.value)
            if candidate.is_valid():
                return candidate
        return None

    def next(self, skip=1) -> "Password":
        # TODO: use some built-in way of doing arbitrary base 26
        carry = 0
        value: List[int] = []
        for i, n in enumerate(reversed(self.value)):
            if i == 0:
                n += skip

            n += carry
            carry = 0

            if self.itoa[n % self.base] in self.badchars:
                # TODO: figure out a way to prune and skip?
                # return self.next(self.base**i)
                pass

            if n >= self.base:
                carry, n = divmod(n, self.base)

            value.append(n)

        return Password("".join(self.itoa[n] for n in reversed(value)))


class Solution:
    key = "11"

    def __init__(self, input: str):
        self.input = input

    def part_one(self) -> Optional[Password]:
        return Password(self.input).next_valid()

    def part_two(self) -> Optional[Password]:
        old = self.part_one()
        if old is None:
            return None
        return old.next_valid()


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
