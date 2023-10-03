from textwrap import dedent
import pytest

from c19 import Solution


@pytest.fixture
def example():
    return dedent(
        """
        e => H
        e => O
        H => HO
        H => OH
        O => HH

        HOH
        """
    ).strip()


@pytest.fixture
def example2():
    return dedent(
        """
        e => H
        e => O
        H => HO
        H => OH
        O => HH

        HOHOHO
        """
    ).strip()


@pytest.fixture
def example3():
    return dedent(
        """
        H => HO
        H => OH
        O => HH

        H2O
        """
    ).strip()


def test_part_one(example, example2, example3):
    assert Solution(example).part_one() == 4
    assert Solution(example2).part_one() == 7
    assert Solution(example3).part_one() == 3


def test_part_two(example, example2):
    assert Solution(example).part_two() == 3
    assert Solution(example2).part_two() == 6
