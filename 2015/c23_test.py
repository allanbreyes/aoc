from textwrap import dedent
import pytest

from c23 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        inc a
        jio a, +2
        tpl a
        inc a
        """
    ).strip()


def test_part_one(example):
    assert Solution(example).part_one()["a"] == 2


def test_part_two(example):
    assert Solution(example).part_two()["a"] == 7
