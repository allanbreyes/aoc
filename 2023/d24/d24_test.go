package d24

import (
	"testing"
)

var input = `19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3`

func TestSubSolvePart1(t *testing.T) {
	got := subSolvePart1(input, 7, 27)
	want := 2
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSubSolvePart2(t *testing.T) {
	t.Skip()
	got := subSolvePart2(input, 1, 5)
	want := 0
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
