import pytest

from c03 import Solution


@pytest.fixture
def example():
    return "^>v<"


def test_part_one(example):
    assert Solution(example).part_one() == 4


def test_part_two(example):
    assert Solution(example).part_two() == 3
