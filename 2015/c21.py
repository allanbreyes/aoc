from dataclasses import dataclass, field
from itertools import combinations
from typing import Generator, Optional, Set, Tuple
import sys


@dataclass
class Stats:
    cost: int
    damage: int
    armor: int


weapons = {
    "Dagger": Stats(8, 4, 0),
    "Shortsword": Stats(10, 5, 0),
    "Warhammer": Stats(25, 6, 0),
    "Longsword": Stats(40, 7, 0),
    "Greataxe": Stats(74, 8, 0),
}

armors = {
    "Leather": Stats(13, 0, 1),
    "Chainmail": Stats(31, 0, 2),
    "Splintmail": Stats(53, 0, 3),
    "Bandedmail": Stats(75, 0, 4),
    "Platemail": Stats(102, 0, 5),
    "None": Stats(0, 0, 0),  # Added manually
}

rings = {
    "Damage +1": Stats(25, 1, 0),
    "Damage +2": Stats(50, 2, 0),
    "Damage +3": Stats(100, 3, 0),
    "Defense +1": Stats(20, 0, 1),
    "Defense +2": Stats(40, 0, 2),
    "Defense +3": Stats(80, 0, 3),
}


@dataclass
class Actor:
    hp: int
    damage: int = 0
    armor: int = 0
    equipment: Set = field(default_factory=set)

    def clone(self) -> "Actor":
        return Actor(self.hp, self.damage, self.armor, self.equipment.copy())

    def equip(self, name: str, stats: Stats) -> int:
        if name in self.equipment:
            raise ValueError("already equipped")

        self.equipment.add(name)
        self.damage += stats.damage
        self.armor += stats.armor
        return stats.cost

    def attack(self, other: "Actor") -> int:
        damage = max(1, self.damage - other.armor)
        other.hp -= damage
        return damage

    def fight(self, other: "Actor", verbose=False) -> bool:
        while self.is_alive and other.is_alive:
            dmg = self.attack(other)
            if verbose:
                print(f"Player({self.hp}) -{dmg}-> Boss({other.hp})")
            if not other.is_alive:
                break

            dmg = other.attack(self)
            if verbose:
                print(f"Boss({other.hp}) -{dmg}-> Player({self.hp})")
            if not self.is_alive:
                break

        return self.is_alive and not other.is_alive

    @property
    def is_alive(self) -> bool:
        return self.hp > 0


class Solution:
    key = "21"

    def __init__(self, input: str, custom_actor: Optional[Actor] = None):
        self.input = input
        self.hero = custom_actor or Actor(100)
        self.boss = self.parse()

    def part_one(self) -> int:
        best = sys.maxsize
        for win, cost in self.generate():
            if win:
                best = min(best, cost)
        return best

    def part_two(self) -> int:
        worst = -1
        for win, cost in self.generate():
            if not win:
                worst = max(worst, cost)
        return worst

    def generate(self) -> Generator[Tuple[bool, int], None, None]:
        for weapon in weapons:
            for armor in armors:
                for num_rings in range(3):
                    for combo in combinations(rings.keys(), num_rings):
                        # Respawn
                        hero = self.hero.clone()
                        boss = self.boss.clone()

                        # Buy
                        cost = hero.equip(weapon, weapons[weapon])
                        cost += hero.equip(armor, armors[armor])
                        for ring in combo:
                            cost += hero.equip(ring, rings[ring])

                        # Fight
                        yield hero.fight(boss), cost

    def parse(self) -> Actor:
        return Actor(*[int(line.split()[-1]) for line in self.input.split("\n")])  # type: ignore


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
