package d10

import (
	"testing"
)

var input1 = `-L|F7
7S-7|
L|7||
-L-J|
L|-JF`

var input2 = `7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ`

func TestSolvePart1a(t *testing.T) {
	got := SolvePart1(input1)
	want := 4
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart1b(t *testing.T) {
	got := SolvePart1(input2)
	want := 8
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input1)
	want := 0
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
