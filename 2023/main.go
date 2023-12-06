package main

import (
	"flag"
	"fmt"
	"os"
	"sort"

	"github.com/allanbreyes/aoc/2023/d01"
	"github.com/allanbreyes/aoc/2023/d02"
	"github.com/allanbreyes/aoc/2023/d03"
	"github.com/allanbreyes/aoc/2023/d04"
	"github.com/allanbreyes/aoc/2023/d05"
	// TODO: insert package here
)

type Solution struct {
	p1 func(string) int
	p2 func(string) int
}

var days = map[int]Solution{
	1: {p1: d01.SolvePart1, p2: d01.SolvePart2},
	2: {p1: d02.SolvePart1, p2: d02.SolvePart2},
	3: {p1: d03.SolvePart1, p2: d03.SolvePart2},
	4: {p1: d04.SolvePart1, p2: d04.SolvePart2},
	5: {p1: d05.SolvePart1, p2: d05.SolvePart2},
	// TODO: insert day here
}

func main() {
	// Get the last day in the map as a default or pull from command-line args
	keys := make([]int, len(days))
	i := 0
	for k := range days {
		keys[i] = k
		i++
	}
	sort.Slice(keys, func(i, j int) bool { return keys[i] < keys[j] })
	last := keys[len(keys)-1]
	day := flag.Int("day", last, "day to run")

	new := false
	flag.BoolVar(&new, "new", false, "generate new file")
	flag.Parse()

	// Generate a new file if requested
	if new {
		New(*day + 1)
		return
	}

	// Run the solution
	fmt.Fprintf(os.Stderr, "🎄 Day %d 🎄\n", *day)
	input := LoadInput(*day, true)
	fmt.Println(days[*day].p1(input))
	fmt.Println(days[*day].p2(input))
}
