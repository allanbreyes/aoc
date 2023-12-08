package d08

import (
	"testing"
)

var input1 = `RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)`

var input2 = `LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)`

var input3 = `LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)`

func TestSolvePart1a(t *testing.T) {
	got := SolvePart1(input1)
	want := 2
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart1b(t *testing.T) {
	got := SolvePart1(input2)
	want := 6
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input3)
	want := 6
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
