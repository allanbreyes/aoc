package main

import (
	"flag"
	"fmt"
	"sort"

	"github.com/allanbreyes/aoc/2023/d01"
)

type Solution struct {
	p1 func(string) int
	p2 func(string) int
}

var days = map[int]Solution{
	1: {p1: d01.SolvePart1, p2: d01.SolvePart2},
	// 2: {p1: d02.SolvePart1, p2: d02.SolvePart2},
}

func main() {
	// Get the last day in the map as a default or pull from command-line args
	keys := make([]int, len(days))
	i := 0
	for k := range days {
		keys[i] = k
		i++
	}
	fmt.Println(keys)
	sort.Slice(keys, func(i, j int) bool { return keys[i] < keys[j] })
	last := keys[len(keys)-1]
	day := flag.Int("day", last, "day to run")
	flag.Parse()

	// Run the solution
	fmt.Printf("🎄 Day %d:\n", *day)
	input := LoadInput(*day, true)
	fmt.Println(days[*day].p1(input))
	fmt.Println(days[*day].p2(input))
}
