package d07

import (
	"testing"
)

var input = `32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 6440
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 5905
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
