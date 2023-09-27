from textwrap import dedent
import pytest

from c06 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        turn on 0,0 through 9,9
        toggle 0,0 through 9,0
        turn off 4,4 through 5,5
    """.strip()
    )


def test_part_one(example):
    assert Solution(example, (10, 10)).part_one() == 86


def test_part_two(example):
    assert Solution(example, (10, 10)).part_two() == 116
