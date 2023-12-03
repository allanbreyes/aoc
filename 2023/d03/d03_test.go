package d03

import (
	"testing"
)

var input = `467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 4361
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 467835
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
