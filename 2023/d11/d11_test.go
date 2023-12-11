package d11

import (
	"testing"
)

var input = `...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 374
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestExpand(t *testing.T) {
	got := Solve(input, 10)
	want := 1030
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}

	got = Solve(input, 100)
	want = 8410
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 82000210
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
