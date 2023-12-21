package d21

import (
	"testing"
)

var input = `...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........`

func TestWalk(t *testing.T) {
	grid, start := parse(input)
	cache := make(WalkCache)
	got := len(walk(6, start, grid, cache))
	want := 16
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 0
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
