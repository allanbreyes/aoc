package d12

import (
	"log"
	"strconv"
	"strings"
)

type Record struct {
	row  string
	vals []int
}

func SolvePart1(input string) (ans int) {
	for _, record := range Parse(input, false) {
		ans += Enumerate(record)
	}
	return
}

func SolvePart2(input string) (ans int) {
	// TODO(perf): speed this up
	records := Parse(input, true)
	log.Println("processing records:", len(records))
	for i, record := range Parse(input, true) {
		log.Println("processing record:", i, record)
		ans += Enumerate(record)
	}
	return
}

func Enumerate(record Record) (ans int) {
	i := strings.Index(record.row, "?")
	if i == -1 {
		if IsValid(record, true) {
			ans++
		}
	} else if !IsValid(record, false) {
		return 0
	} else {
		ans += Enumerate(Record{strings.Replace(record.row, "?", ".", 1), record.vals})
		ans += Enumerate(Record{strings.Replace(record.row, "?", "#", 1), record.vals})
	}

	return ans
}

func IsValid(record Record, full bool) bool {
	streak := 0
	vals := record.vals
	last := '?'

	row := record.row
	if !full {
		j := strings.Index(row, "?")
		if j != -1 {
			row = row[:j]
		}
	}

	for i, char := range row {
		if i == 0 {
			last = char
		}
		switch char {
		case '?':
			log.Fatalf("resolve all unknowns first")
		case '.':
			{
				if last == '#' {
					// No more streaks left
					if len(vals) == 0 {
						return false
					}

					// Get and check the next streak, reset if still valid
					val := vals[0]
					vals = vals[1:]
					if streak != val {
						return false
					}
					streak = 0
				}
			}
		case '#':
			streak++
		}

		last = char
	}

	// Bail early if it's a partial check
	if !full {
		return true
	}

	// If one streak remains, check it
	if len(vals) == 1 {
		return streak == vals[0]
	}

	// Valid if no streak or values remain
	return len(vals) == 0 && streak == 0
}

func unfold(record Record) (new Record) {
	strs := []string{}
	vals := []int{}
	for i := 0; i < 5; i++ {
		strs = append(strs, string(record.row))
		vals = append(vals, record.vals...)
	}
	row := strings.Join(strs, "?")
	return Record{row, vals}
}

func Parse(input string, folded bool) (records []Record) {
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		parts := strings.Split(line, " ")
		vals := []int{}
		for _, num := range strings.Split(parts[1], ",") {
			val, _ := strconv.Atoi(num)
			vals = append(vals, val)
		}
		record := Record{parts[0], vals}
		if folded {
			record = unfold(record)
		}
		records = append(records, record)
	}
	return records
}
