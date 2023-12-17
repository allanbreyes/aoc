package d17

import (
	"testing"
)

var input = `2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 102
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 94
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
