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
	"github.com/allanbreyes/aoc/2023/d06"
	"github.com/allanbreyes/aoc/2023/d07"
	"github.com/allanbreyes/aoc/2023/d08"
	"github.com/allanbreyes/aoc/2023/d09"
	"github.com/allanbreyes/aoc/2023/d10"
	"github.com/allanbreyes/aoc/2023/d11"
	"github.com/allanbreyes/aoc/2023/d12"
	"github.com/allanbreyes/aoc/2023/d13"
	"github.com/allanbreyes/aoc/2023/d14"
	"github.com/allanbreyes/aoc/2023/d15"
	"github.com/allanbreyes/aoc/2023/d16"
	"github.com/allanbreyes/aoc/2023/d17"
	"github.com/allanbreyes/aoc/2023/d18"
	"github.com/allanbreyes/aoc/2023/d19"
	"github.com/allanbreyes/aoc/2023/d20"
	"github.com/allanbreyes/aoc/2023/d21"
	"github.com/allanbreyes/aoc/2023/d22"
	"github.com/allanbreyes/aoc/2023/d23"
	"github.com/allanbreyes/aoc/2023/d24"
	// "github.com/allanbreyes/aoc/2023/d25"
)

type Solution struct {
	p1 func(string) int
	p2 func(string) int
}

var days = map[int]Solution{
	1:  {p1: d01.SolvePart1, p2: d01.SolvePart2},
	2:  {p1: d02.SolvePart1, p2: d02.SolvePart2},
	3:  {p1: d03.SolvePart1, p2: d03.SolvePart2},
	4:  {p1: d04.SolvePart1, p2: d04.SolvePart2},
	5:  {p1: d05.SolvePart1, p2: d05.SolvePart2},
	6:  {p1: d06.SolvePart1, p2: d06.SolvePart2},
	7:  {p1: d07.SolvePart1, p2: d07.SolvePart2},
	8:  {p1: d08.SolvePart1, p2: d08.SolvePart2},
	9:  {p1: d09.SolvePart1, p2: d09.SolvePart2},
	10: {p1: d10.SolvePart1, p2: d10.SolvePart2},
	11: {p1: d11.SolvePart1, p2: d11.SolvePart2},
	12: {p1: d12.SolvePart1, p2: d12.SolvePart2},
	13: {p1: d13.SolvePart1, p2: d13.SolvePart2},
	14: {p1: d14.SolvePart1, p2: d14.SolvePart2},
	15: {p1: d15.SolvePart1, p2: d15.SolvePart2},
	16: {p1: d16.SolvePart1, p2: d16.SolvePart2},
	17: {p1: d17.SolvePart1, p2: d17.SolvePart2},
	18: {p1: d18.SolvePart1, p2: d18.SolvePart2},
	19: {p1: d19.SolvePart1, p2: d19.SolvePart2},
	20: {p1: d20.SolvePart1, p2: d20.SolvePart2},
	21: {p1: d21.SolvePart1, p2: d21.SolvePart2},
	22: {p1: d22.SolvePart1, p2: d22.SolvePart2},
	23: {p1: d23.SolvePart1, p2: d23.SolvePart2},
	24: {p1: d24.SolvePart1, p2: d24.SolvePart2},
	// 25: {p1: d25.SolvePart1, p2: d25.SolvePart2},
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
