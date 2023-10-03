import pytest

from c16 import Solution


@pytest.fixture
def example():
    return open(f"inputs/{Solution.key}.txt", "r").read().strip()


def test_part_one(example):
    assert Solution(example).part_one() == 103


def test_part_two(example):
    assert Solution(example).part_two() == 405
