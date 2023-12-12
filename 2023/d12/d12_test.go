package d12

import (
	"testing"
)

var original = `#.#.### 1,1,3
.#...#....###. 1,1,3
.#.###.#.###### 1,3,1,6
####.#...#... 4,1,1
#....######..#####. 1,6,5
.###.##....# 3,2,1`

var input = `???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1`

func TestIsValid(t *testing.T) {
	for _, record := range Parse(original, false) {
		if !IsValid(record, true) {
			t.Errorf("record %v is invalid", record)
		}

		for i, _ := range record.row {
			partial := Record{record.row[:i], record.vals}
			if !IsValid(partial, false) {
				t.Errorf("record %v is partially invalid", partial)
			}
		}
	}
}

func TestEnumerate(t *testing.T) {
	expected := []int{1, 4, 1, 1, 4, 10}
	for i, record := range Parse(input, false) {
		got := Enumerate(record)
		want := expected[i]
		if got != want {
			t.Errorf("got %d, want %d (%v)", got, want, record)
		}
	}
}

func TestSolvePart1(t *testing.T) {
	got := SolvePart1(input)
	want := 21
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}

func TestSolvePart2(t *testing.T) {
	got := SolvePart2(input)
	want := 525152
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
