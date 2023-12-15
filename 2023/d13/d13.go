package d13

import (
	"log"
	"math/bits"
	"strings"
)

// Pattern represents the 2D rock/ash pattern with a binary representation,
// where each 1 is a rock (#) and each 0 is ash (.). The row-wise and col-wise
// projections are pre-computed during parsing.
type Pattern struct {
	rows []uint
	cols []uint
}

func solve(input string, errors int) (ans int) {
	for _, pattern := range parse(input) {
		row, rowlen := findPivot(pattern.rows, errors)
		col, collen := findPivot(pattern.cols, errors)
		if row == -1 && col == -1 {
			log.Fatalf("no pivot found for pattern %v", pattern)
		} else if rowlen > collen {
			ans += row * 100
		} else {
			ans += col
		}
	}
	return
}

func SolvePart1(input string) (ans int) {
	return solve(input, 0)
}

func SolvePart2(input string) (ans int) {
	return solve(input, 1)
}

func findPivot(seq []uint, errors int) (index int, maxlen int) {
	index = -1

	for i := 1; i < len(seq); i++ {
		e := 0
		count := 0
		for j := i; j < len(seq) && 2*i-j-1 >= 0; j++ {
			// Fold the sequence in half and accumulate errors via XOR
			k := 2*i - j - 1
			e += bits.OnesCount(seq[j] ^ seq[k])

			// Bail early if we've exceeded the error threshold
			if e > errors {
				break
			}
			count++
		}

		// Update the pivot if we've found a longer sequence
		if e == errors && count > maxlen {
			maxlen = count
			index = i
		}
	}
	return index, maxlen
}

func parse(input string) (patterns []Pattern) {
	for _, group := range strings.Split(strings.TrimSpace(input), "\n\n") {
		lines := strings.Split(group, "\n")
		rows := make([]uint, len(lines))
		cols := make([]uint, len(lines[0]))
		for i, line := range lines {
			rows[i] = uint(1)
			for j, char := range line {
				rows[i] <<= 1
				if i == 0 {
					cols[j] = uint(1)
				} else {
					cols[j] <<= 1
				}

				switch char {
				case '#':
					rows[i] |= 1
					cols[j] |= 1
				case '.':
				default:
					log.Fatalf("unexpected char %q", char)
				}
			}
		}
		patterns = append(patterns, Pattern{rows, cols})
	}

	return patterns
}
