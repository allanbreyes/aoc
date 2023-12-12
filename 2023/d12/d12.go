package d12

import (
	"fmt"
	"strconv"
	"strings"
)

type Record struct {
	row    string
	groups []int
	streak bool
}

func (r Record) Key() (key string) {
	// NOTE: There's surely a better way to memoize function arguments a la
	// Python's @cache. This ain't it.
	return fmt.Sprintf("%s:%v:%v", r.row, r.groups, r.streak)
}

func SolvePart1(input string) (ans int) {
	cache := map[string]int{}
	for _, record := range Parse(input, false) {
		ans += Enumerate(record, cache)
	}
	return
}

func SolvePart2(input string) (ans int) {
	cache := map[string]int{}
	for _, record := range Parse(input, true) {
		ans += Enumerate(record, cache)
	}
	return
}

func Enumerate(record Record, cache map[string]int) (ans int) {
	// Use memoized value if available
	key := record.Key()
	if val, ok := cache[key]; ok {
		return val
	}

	// Base case
	if len(record.row) == 0 {
		if len(record.groups) == 0 {
			return 1
		}
		return 0
	}

	head := record.row[0]
	if (head == '#' || head == '?') && len(record.groups) > 0 && record.groups[0] > 0 {
		// Continue streak
		groups := []int{record.groups[0] - 1}
		groups = append(groups, record.groups[1:]...)
		ans += Enumerate(Record{record.row[1:], groups, true}, cache)
	}
	if head == '.' || head == '?' {
		// Streak broken in a valid way
		if record.streak && len(record.groups) > 0 && record.groups[0] == 0 {
			ans += Enumerate(Record{record.row[1:], record.groups[1:], false}, cache)
		}

		// Continue
		if !record.streak {
			ans += Enumerate(Record{record.row[1:], record.groups, false}, cache)
		}
	}

	cache[key] = ans
	return ans
}

func unfold(record Record) (new Record) {
	strs := []string{}
	groups := []int{}
	for i := 0; i < 5; i++ {
		strs = append(strs, string(record.row))
		groups = append(groups, record.groups...)
	}
	row := strings.Join(strs, "?")
	return Record{row, groups, false}
}

func Parse(input string, folded bool) (records []Record) {
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		parts := strings.Split(line, " ")
		groups := []int{}
		for _, num := range strings.Split(parts[1], ",") {
			group, _ := strconv.Atoi(num)
			groups = append(groups, group)
		}
		record := Record{parts[0], groups, false}
		if folded {
			record = unfold(record)
		}
		record.row = record.row + "." // HACK: Break streaks before last iter
		records = append(records, record)
	}
	return records
}
