package d06

import (
	"regexp"
	"strconv"
	"strings"
)

func SolvePart1(input string) int {
	times, dists := parse(input, true)

	races := make([]int, len(times))
	for i, duration := range times {
		record := dists[i]
		for t := 1; t < duration; t++ {
			v := t
			win := v*(duration-t) > record
			if win {
				races[i] += 1
			}
		}
	}

	ans := 1
	for _, wins := range races {
		ans *= wins
	}
	return ans
}

func SolvePart2(input string) int {
	times, dists := parse(input, false)
	duration := times[0]
	record := dists[0]

	wins := 0
	for t := 1; t < duration; t++ {
		v := t
		win := v*(duration-t) > record
		if win {
			wins += 1
		}
	}
	return wins
}

func parse(input string, delimited bool) ([]int, []int) {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	re := regexp.MustCompile(`\d+`)
	timeTokens := re.FindAllString(lines[0], -1)
	distTokens := re.FindAllString(lines[1], -1)
	times := []int{}
	dists := []int{}

	if delimited {
		for _, token := range timeTokens {
			time, _ := strconv.Atoi(token)
			times = append(times, time)
		}
		for _, token := range distTokens {
			dist, _ := strconv.Atoi(token)
			dists = append(dists, dist)
		}
	} else {
		time, _ := strconv.Atoi(strings.Join(timeTokens, ""))
		times = append(times, time)
		dist, _ := strconv.Atoi(strings.Join(distTokens, ""))
		dists = append(dists, dist)
	}

	return times, dists
}
