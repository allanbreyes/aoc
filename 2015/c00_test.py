import pytest

from c00 import Solution


@pytest.fixture
def example():
    return None


def test_part_one(example):
    assert Solution(example).part_one() is None


def test_part_two(example):
    assert Solution(example).part_two() is None
