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

var input3 = `S-------7
|F-----7|
||.....||
||.....||
|L-7.F-J|
|..|.|..|
L--J.L--J`

var input3a = `S------7
|F----7|
||....||
||....||
|L-7F-J|
|..||..|
L--JL--J`

var input4 = `.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...`

var input5 = `FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L`

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

func TestSolvePart2a(t *testing.T) {
	got := SolvePart2(input3)
	want := 4
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}

	got = SolvePart2(input3a)
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2b(t *testing.T) {
	got := SolvePart2(input4)
	want := 8
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2c(t *testing.T) {
	got := SolvePart2(input5)
	want := 10
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
