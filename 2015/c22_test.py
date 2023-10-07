from textwrap import dedent
import pytest

from c22 import Actor, Solution


@pytest.fixture
def example():
    return dedent(
        """
        Hit Points: 14
        Damage: 8
        """
    ).strip()


@pytest.mark.skip("slow")
def test_part_one(example):
    assert Solution(example).part_one() is None


@pytest.mark.skip
def test_part_two(example):
    assert Solution(example).part_two() is None
