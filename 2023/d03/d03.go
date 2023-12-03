package d03

import (
	"regexp"
	"strconv"
	"strings"
)

type Position struct {
	row int
	col int
}

func SolvePart1(input string) int {
	schematic := parse(input)
	sum := 0

	isnumber := regexp.MustCompile(`\d+`)
	haspart := regexp.MustCompile(`[^\d.]`)

	for i, row := range schematic {
		matches := isnumber.FindAllStringIndex(row, -1)
		for _, match := range matches {
			num, err := strconv.Atoi(row[match[0]:match[1]])
			if err != nil {
				panic(err)
			}

			top := schematic[i-1][match[0]-1 : match[1]+1]
			right := row[match[1] : match[1]+1]
			bottom := schematic[i+1][match[0]-1 : match[1]+1]
			left := row[match[0]-1 : match[0]]

			if haspart.MatchString(top) || haspart.MatchString(right) || haspart.MatchString(bottom) || haspart.MatchString(left) {
				sum += num
			}
		}
	}
	return sum
}

func SolvePart2(input string) int {
	schematic := parse(input)
	sum := 0

	isnumber := regexp.MustCompile(`\d+`)
	hasgear := regexp.MustCompile(`\*`)

	gears := make(map[Position][]int)

	for i, row := range schematic {
		matches := isnumber.FindAllStringIndex(row, -1)
		for _, match := range matches {
			num, err := strconv.Atoi(row[match[0]:match[1]])
			if err != nil {
				panic(err)
			}

			top := schematic[i-1][match[0]-1 : match[1]+1]
			right := row[match[1] : match[1]+1]
			bottom := schematic[i+1][match[0]-1 : match[1]+1]
			left := row[match[0]-1 : match[0]]

			if hasgear.MatchString(top) {
				gearmatch := hasgear.FindStringIndex(top)
				gear := Position{row: i - 1, col: match[0] + gearmatch[0] - 1}
				gears[gear] = append(gears[gear], num)
			} else if hasgear.MatchString(right) {
				gear := Position{row: i, col: match[1]}
				gears[gear] = append(gears[gear], num)
			} else if hasgear.MatchString(bottom) {
				gearmatch := hasgear.FindStringIndex(bottom)
				gear := Position{row: i + 1, col: match[0] + gearmatch[0] - 1}
				gears[gear] = append(gears[gear], num)
			} else if hasgear.MatchString(left) {
				gear := Position{row: i, col: match[0] - 1}
				gears[gear] = append(gears[gear], num)
			}
		}
	}

	for _, gear := range gears {
		if len(gear) == 2 {
			sum += gear[0] * gear[1]
		}
	}
	return sum
}

func parse(input string) []string {
	rows := strings.Split(strings.TrimSpace(input), "\n")
	l := len(rows[0])

	res := make([]string, 0)
	pad := strings.Repeat(".", l+2)
	res = append(res, pad)
	for _, row := range rows {
		res = append(res, "."+row+".")
	}
	res = append(res, pad)
	return res
}
