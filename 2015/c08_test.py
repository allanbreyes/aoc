from textwrap import dedent
import pytest

from c08 import Solution


@pytest.fixture
def example():
    return dedent(
        """\
        ""
        "abc"
        "aaa\\"aaa"
        "\\x27"
    """
    ).strip()


@pytest.mark.skip("has an eval")
def test_part_one(example):
    assert Solution(example).part_one() == 12


def test_part_two(example):
    assert Solution(example).part_two() == 19
