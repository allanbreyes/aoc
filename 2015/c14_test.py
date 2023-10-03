from textwrap import dedent
import pytest

from c14 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
        Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.
        """
    ).strip()


def test_part_one(example):
    assert Solution(example, 1000).part_one() == 1120


def test_part_two(example):
    assert Solution(example, 1000).part_two() == 689
