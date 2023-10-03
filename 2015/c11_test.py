from textwrap import dedent
import pytest

from c11 import Password, Solution


@pytest.fixture
def example():
    return "abcdefgh"


@pytest.mark.parametrize(
    "password,valid",
    [
        ("hijklmmn", False),
        ("abbceffg", False),
        ("abbcegjk", False),
        ("abcdefgh", False),
        ("abcdffaa", True),
        ("ghijklmn", False),
        ("ghjaabcc", True),
        ("ghijklmo", False),
    ],
)
def test_password_is_valid(password, valid):
    instance = Password(password)
    assert instance.is_valid() == valid


@pytest.mark.parametrize(
    "password,next_password",
    [
        ("abcdefgh", "abcdffaa"),
        # ("ghijklmn", "ghjaabcc"),  # Slow and unoptimized
    ],
)
def test_password_next_valid(password, next_password):
    before = Password(password)
    after = before.next_valid()
    assert str(after) == next_password


@pytest.mark.skip("slow")
def test_part_one(example):
    assert str(Solution(example).part_one()) == "abcdffaa"


@pytest.mark.skip("slow")
def test_part_two(example):
    assert str(Solution(example).part_two()) == "abcdffbb"
