# This is horribly not performant! Please don't look at or use this code :O
from dataclasses import dataclass, field
from enum import auto, Enum
from typing import Any, List, Optional, Tuple
import os
import sys

VERBOSE = os.getenv("VERBOSE", False)


def log(*msg: Any):
    if VERBOSE:
        print(*msg)


@dataclass
class Environment:
    hero: "Actor"
    boss: "Actor"
    effects: List["Spell"] = field(default_factory=list)

    def clone(self) -> "Environment":
        return Environment(
            hero=self.hero.clone(),
            boss=self.boss.clone(),
            effects=[effect.clone() for effect in self.effects],
        )

    def get_actions(self) -> List["Spell"]:
        spells = [spell() for spell in SPELLS]
        return [spell for spell in spells if spell.check(self)]

    def proc(self):
        for effect in self.effects:
            effect.proc(self)
        self.effects = [e for e in self.effects if e.is_active]


class Spell:
    cost = 0
    damage = 0
    heal = 0
    armor = 0
    recharge = 0
    duration = -1

    def __init__(self):
        self.timer = self.duration if self.duration != -1 else None

    def __str__(self) -> str:
        return f"{self.name}({self.timer})" if self.is_effect else f"{self.name}()"

    def __repr__(self) -> str:
        return self.__str__()

    def clone(self) -> "Spell":
        clone = self.__class__()
        clone.timer = self.timer
        return clone

    @property
    def name(self) -> str:
        return self.__class__.__name__

    @property
    def is_effect(self) -> bool:
        return self.duration != -1

    @property
    def is_active(self) -> bool:
        return self.timer > 0

    def check(self, env: Environment) -> bool:
        if env.hero.mana < self.cost:
            return False

        if self.is_effect:
            # TODO: fix O(mn) lookups
            for effect in env.effects:
                if self.name == effect.name:
                    return False

        return True

    def proc(self, env: Environment):
        raise NotImplementedError


class MagicMissile(Spell):
    cost = 53
    damage = 4

    def proc(self, env: Environment):
        env.boss.hp -= self.damage
        log(f"{self} hit boss for {self.damage} Boss({env.boss.hp})")


class Drain(Spell):
    cost = 73
    damage = 2
    heal = 2

    def proc(self, env: Environment):
        env.boss.hp -= self.damage
        env.hero.hp += self.heal
        log(
            f"{self} drained {self.damage} from Boss({env.boss.hp}) to Hero({env.hero.hp})"
        )


class Shield(Spell):
    cost = 113
    armor = 7
    duration = 6

    def proc(self, env: Environment):
        if self.timer == self.duration:
            log(f"{self} provides {self.armor} armor to {env.hero}")
            env.hero.armor += self.armor

        self.timer -= 1
        if self.timer <= 0:
            log(f"{self} wears off")
            env.hero.armor -= self.armor


class Poison(Spell):
    cost = 173
    damage = 3
    duration = 6

    def proc(self, env: Environment):
        self.timer -= 1
        env.boss.hp -= self.damage
        log(f"{self} dealt {self.damage} to {env.boss}")

        if self.timer <= 0:
            log(f"{self} wears off")


class Recharge(Spell):
    cost = 229
    duration = 5
    recharge = 101

    def proc(self, env: Environment):
        self.timer -= 1
        env.hero.mana += self.recharge
        log(f"{self} provides {self.recharge} to {env.hero}")

        if self.timer <= 0:
            log(f"{self} wears off")


SPELLS = [MagicMissile, Drain, Shield, Poison, Recharge]


@dataclass
class Actor:
    hp: int
    mana: int = 0
    damage: int = 0
    armor: int = 0
    name: str = "Actor"

    def __str__(self) -> str:
        return f"{self.name}({self.hp})"

    def status(self) -> str:
        return f"{self.name}(hp={self.hp}, mana={self.mana}, armor={self.armor}"

    def clone(self) -> "Actor":
        return Actor(
            hp=self.hp,
            mana=self.mana,
            damage=self.damage,
            armor=self.armor,
            name=self.name,
        )

    def attack(self, other: "Actor") -> int:
        damage = max(1, self.damage - other.armor)
        other.hp -= damage
        log(f"{self} deals {damage} damage to {other}")
        return damage

    def cast(self, spell: Spell, env: Environment) -> int:
        if not spell.check(env):
            raise ValueError("cannot cast")

        log(f"{env.hero} casts {spell}")

        if spell.is_effect:
            env.effects.append(spell)
        else:
            spell.proc(env)

        return spell.cost

    @property
    def is_alive(self) -> bool:
        return self.hp > 0


class Result(Enum):
    WIN = auto()
    LOSE = auto()
    NA = auto()

    @property
    def ended(self) -> bool:
        return self != Result.NA


class Solution:
    key = "22"

    def __init__(self, input: str, hero: Optional[Actor] = None):
        self.input = input
        self.boss = self.parse()
        self.boss.name = "Boss"
        self.hero = hero or Actor(50, 500)
        self.hero.name = "Hero"

    def battle(self):
        env = Environment(self.hero.clone(), self.boss.clone())
        hero, boss = env.hero, env.boss

        spells = [
            Recharge(),
            Shield(),
            Drain(),
            Poison(),
            MagicMissile(),
        ]

        for i in range(10):
            log(f"{i}:" + "=" * 80)
            log(hero, "vs.", boss)
            log(env.get_actions())
            self.tick(env, spells.pop(0))

    def tick(
        self, env: Environment, spell: Spell, dot: bool = False
    ) -> Tuple[Result, int]:
        env.proc()
        mana = env.hero.cast(spell, env)
        if not env.boss.is_alive:
            log(f"{env.boss} is dead!")
            return Result.WIN, mana

        env.proc()
        if not env.boss.is_alive:
            log(f"{env.boss} is dead!")
            return Result.WIN, mana

        env.boss.attack(env.hero)
        if not env.hero.is_alive:
            log(f"{env.hero} is dead!")
            return Result.LOSE, mana

        return Result.NA, mana

    def simulate(self, env: Environment, spell: Spell, depth: int = 100) -> int:
        best = sys.maxsize

        if depth <= 0:
            return best

        env = env.clone()
        result, mana = self.tick(env, spell)

        if result == result.WIN:
            return mana
        elif result == result.LOSE:
            return best

        for action in env.get_actions():
            future = self.simulate(env, action, depth - 1)
            best = min(best, future)

        return best + mana

    def part_one(self) -> int:
        env = Environment(self.hero, self.boss)
        return min(self.simulate(env, start) for start in env.get_actions())

    def part_two(self) -> Optional[str]:
        pass

    def parse(self):
        hp, damage = [int(line.split()[-1]) for line in self.input.split("\n")]
        return Actor(hp, 0, damage)


if __name__ == "__main__":
    with open(f"./inputs/{Solution.key}.txt", "r") as fh:
        input = fh.read().strip()
    print("Part 1:", Solution(input).part_one())
    print("Part 2:", Solution(input).part_two())
