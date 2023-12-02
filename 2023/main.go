package main

import "fmt"

func main() {
	// TODO: dynamically call day/part with CLI args
	day := 1
	fmt.Printf("🎄 Day %d:\n", day)
	input := LoadInput(day, true)
	fmt.Println(Day1Part1(input))
	fmt.Println(Day1Part2(input))
}
