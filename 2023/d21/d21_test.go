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

func TestSolve(t *testing.T) {
	got := Solve(input, 6, false)
	want := 16
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolveTiled(t *testing.T) {
	cases := map[int]int{
		6:   16,
		10:  50,
		50:  1594,
		100: 6536,
		// 500: 167004,
	}

	for steps, want := range cases {
		got := Solve(input, steps, true)
		if got != want {
			t.Errorf("for %d steps, got %d, want %d", steps, got, want)
		}
	}
}
