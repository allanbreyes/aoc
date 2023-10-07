from textwrap import dedent
import pytest

from c25 import Solution


@pytest.fixture
def example():
    return "Enter the code at row 4, column 4."


def test_next(example):
    assert Solution(example).next() == 20151125
    assert Solution(example).next(20151125) == 31916031


def test_part_one(example):
    assert Solution(example).part_one() == 9380097
