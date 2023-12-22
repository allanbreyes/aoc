package d22

import (
	"testing"
)

var input = `1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9`

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 5
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 7
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
