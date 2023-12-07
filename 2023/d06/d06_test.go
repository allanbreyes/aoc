package d06

import (
	"testing"
)

var input = `Time:      7  15   30
Distance:  9  40  200`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 288
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 71503
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
