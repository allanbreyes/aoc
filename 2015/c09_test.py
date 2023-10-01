from textwrap import dedent
import pytest

from c09 import Solution


@pytest.fixture
def example():
    return dedent(
        """\
        London to Dublin = 464
        London to Belfast = 518
        Dublin to Belfast = 141
    """
    ).strip()


def test_part_one(example):
    assert Solution(example).part_one() == 605


def test_part_two(example):
    assert Solution(example).part_two() == 982
