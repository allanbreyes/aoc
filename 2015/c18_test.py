from textwrap import dedent
import pytest

from c18 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        .#.#.#
        ...##.
        #....#
        ..#...
        #.#..#
        ####..
        """
    ).strip()


def test_part_one(example):
    assert Solution(example, 6, 4).part_one() == 4


def test_part_two(example):
    assert Solution(example, 6, 5).part_two() == 17
