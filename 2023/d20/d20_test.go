package d20

import (
	"testing"
)

var input1 = `broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a`

var input2 = `broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output`

var input3 = `broadcaster -> a
%a -> inv, con, agg
&inv -> b, agg
%b -> con, agg
&con -> agg
&agg -> rx`

func TestSolvePart1a(t *testing.T) {
	got := SolvePart1(input1)
	want := 32000000
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart1b(t *testing.T) {
	got := SolvePart1(input2)
	want := 11687500
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input3)
	want := 2
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
