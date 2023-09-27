import pytest

from c02 import Solution


@pytest.fixture
def example():
    return "2x3x4\n1x1x10"


def test_part_one(example):
    assert Solution(example).part_one() == 58 + 43


def test_part_two(example):
    assert Solution(example).part_two() == 34 + 14
