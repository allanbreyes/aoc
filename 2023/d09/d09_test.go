package d09

import (
	"testing"
)

var input = `0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 114
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 2
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
