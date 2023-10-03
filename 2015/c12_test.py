from textwrap import dedent
import pytest

from c12 import Solution


@pytest.mark.parametrize(
    "example,expected",
    [
        ("[1,2,3]", 6),
        ('{"a":2,"b":4}', 6),
        ("[[[3]]]", 3),
        ('{"a":{"b":4},"c":-1}', 3),
        ('{"a":[-1,1]}', 0),
        ('[-1,{"a":1}]', 0),
        ("[]", 0),
        ("{}", 0),
    ],
)
def test_part_one(example, expected):
    assert Solution(example).part_one() == expected


@pytest.mark.parametrize(
    "example,expected",
    [
        ('[1,{"c":"red","b":2},3]', 4),
        ('{"d":"red","e":[1,2,3,4],"f":5}', 0),
        ('[1,"red",5]', 6),
    ],
)
def test_part_two(example, expected):
    assert Solution(example).part_two() == expected
