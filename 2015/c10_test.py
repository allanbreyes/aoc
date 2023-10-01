from textwrap import dedent
import pytest

from c10 import Solution


@pytest.fixture
def example():
    return dedent(
        """\
        foo
        bar
        baz
    """
    ).strip()


@pytest.mark.parametrize(
    "input,expected",
    [
        ("1", "11"),
        ("11", "21"),
        ("21", "1211"),
        ("1211", "111221"),
        ("111221", "312211"),
    ],
)
def test_part_one(input, expected):
    sol = Solution(example)
    assert sol.say(input) == expected
