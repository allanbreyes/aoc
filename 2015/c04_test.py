import pytest

from c04 import Solution


@pytest.fixture
def example():
    return "abcdef"


@pytest.mark.skip(reason="slow")
def test_part_one(example):
    assert Solution(example).part_one() == 609043


@pytest.mark.skip(reason="slower")
def test_part_two(example):
    assert Solution(example).part_two() == 6742839
