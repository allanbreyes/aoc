package d15

import (
	"testing"
)

var input = `rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7`

func TestHash(t *testing.T) {
	got := Hash("HASH")
	want := 52
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 1320
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 145
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
