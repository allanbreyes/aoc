import pytest

from c01 import Solution


@pytest.fixture
def example():
    return "(()))("

def test_part_one(example):
    assert Solution(example).part_one() == 0


def test_part_two(example):
    assert Solution(example).part_two() == 5
