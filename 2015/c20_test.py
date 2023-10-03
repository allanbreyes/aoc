from textwrap import dedent
import pytest

from c20 import Solution


@pytest.fixture
def example():
    return "130"


def test_part_one(example):
    assert Solution(example).part_one() == 8


def test_part_two(example):
    assert Solution(example).part_two() == 6
