package d13

import (
	"testing"
)

var input = `#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 405
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 400
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
