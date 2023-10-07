from textwrap import dedent
import pytest

from c24 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        1
        2
        3
        4
        5
        7
        8
        9
        10
        11
        """
    ).strip()


def test_part_one(example):
    assert Solution(example).part_one() == 99


def test_part_two(example):
    assert Solution(example).part_two() == 44
