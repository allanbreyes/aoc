from textwrap import dedent
import pytest

from c00 import Solution


@pytest.fixture
def example():
    return dedent(
        """\
        foo
        bar
        baz
    """
    ).strip()


def test_part_one(example):
    assert Solution(example).part_one() is None


def test_part_two(example):
    assert Solution(example).part_two() is None
