from textwrap import dedent
import pytest

from c21 import Actor, Solution


@pytest.fixture
def example():
    return dedent(
        """
        Hit Points: 12
        Damage: 7
        Armor: 2
        """
    ).strip()


def test_part_one(example):
    assert Solution(example).part_one() == 8


def test_part_two(example):
    assert Solution(example, custom_actor=Actor(10)).part_two() == 148
