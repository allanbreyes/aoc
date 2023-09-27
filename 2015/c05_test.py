import pytest

from c05 import Solution


@pytest.fixture
def example():
    return "ugknbfddgicrmopn\naaa\njchzalrnumimnmhp\nhaegwjzuvuyypxyu\ndvszwmarrgswjxmb"


@pytest.fixture
def example2():
    return "qjhvhtzxzqqjkmpb\nxxyxx\nuurcxstgmygtbstg\nieodomkazucvgmuy"


def test_part_one(example):
    assert Solution(example).part_one() == 2


def test_part_two(example2):
    assert Solution(example2).part_two() == 2
