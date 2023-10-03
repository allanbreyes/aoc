from textwrap import dedent
import pytest

from c17 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        20
        15
        10
        5
        5
        """
    ).strip()


def test_part_one(example):
    assert Solution(example, 25).part_one() == 4


def test_part_two(example):
    assert Solution(example, 25).part_two() == 3
