package d14

import (
	"testing"
)

var input = `O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 136
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 64
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
