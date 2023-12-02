package main

import (
	"regexp"
	"strings"
	"unicode"
)

var digits = map[string]int{
	"one":   1,
	"two":   2,
	"three": 3,
	"four":  4,
	"five":  5,
	"six":   6,
	"seven": 7,
	"eight": 8,
	"nine":  9,
	"zero":  0,
}

func Day1Part1(input string) int {
	sum := 0
	for _, line := range parse(input) {
		left := -1
		right := -1
		for _, char := range line {
			if unicode.IsDigit(char) {
				if left == -1 {
					left = int(char - '0')
				}
				right = int(char - '0')
			}
		}
		sum += left*10 + right
	}
	return sum
}

func Day1Part2(input string) int {
	sum := 0
	re := regexp.MustCompile("one|two|three|four|five|six|seven|eight|nine|zero")

	for _, line := range parse(input) {
		var left, right int

		for j := 0; j < len(line); j++ {
			if j >= 3 {
				match := re.FindString(line[:j])
				if match != "" {
					left = digits[match]
					break
				}
			}
			if unicode.IsDigit(rune(line[j])) {
				left = int(line[j] - '0')
				break
			}
		}

		j := len(line)
		for i := len(line) - 1; i >= 0; i-- {
			if j-i >= 3 {
				match := re.FindString(line[i:j])
				if match != "" {
					right = digits[match]
					break
				}
			}
			if unicode.IsDigit(rune(line[i])) {
				right = int(line[i] - '0')
				break
			}
		}
		sum += left*10 + right
	}
	return sum
}

func parse(input string) []string {
	lines := []string{}
	for _, line := range strings.Split(input, "\n") {
		if line != "" {
			lines = append(lines, line)
		}
	}
	return lines
}
