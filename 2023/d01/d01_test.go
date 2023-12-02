package d01

import (
	"testing"
)

var day = 1

func TestDay1Part1(t *testing.T) {
	input := `1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet`
	got := SolvePart1(input)
	want := 142
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestDay1Part2(t *testing.T) {
	input := `two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen`
	got := SolvePart2(input)
	want := 281
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
