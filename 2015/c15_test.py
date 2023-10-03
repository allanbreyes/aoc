from textwrap import dedent
import pytest

from c15 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
        Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3
        """
    ).strip()


def test_part_one(example):
    assert Solution(example).part_one() == 62842880


def test_part_two(example):
    assert Solution(example).part_two() == 57600000
