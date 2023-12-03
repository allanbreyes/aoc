package d02

import (
	"regexp"
	"strconv"
	"strings"
)

type Draw struct {
	red   int
	green int
	blue  int
}

type Game struct {
	id    int
	draws []Draw
}

func SolvePart1(input string) int {
	max := Draw{red: 12, green: 13, blue: 14}
	games := parse(input)
	sum := 0

	for _, game := range games {
		valid := true
		for _, draw := range game.draws {
			if draw.red > max.red || draw.green > max.green || draw.blue > max.blue {
				valid = false
				break
			}
		}

		if valid {
			sum += game.id
		}
	}

	return sum
}

func SolvePart2(input string) int {
	games := parse(input)
	sum := 0

	for _, game := range games {
		min := Draw{}
		for _, draw := range game.draws {
			min.red = max(min.red, draw.red)
			min.green = max(min.green, draw.green)
			min.blue = max(min.blue, draw.blue)
		}
		sum += min.red * min.green * min.blue
	}

	return sum
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func parse(input string) []Game {
	var games []Game

	gamepattern := regexp.MustCompile(`Game (\d+): (.*)`)
	matches := gamepattern.FindAllStringSubmatch(input, -1)
	for _, match := range matches {
		id, err := strconv.Atoi(match[1])
		if err != nil {
			panic(err)
		}

		var draws []Draw
		rest := strings.Split(match[2], ";")
		for group := range rest {
			draw := Draw{}
			drawpattern := regexp.MustCompile(`(\d+) (\w+)`)
			drawmatches := drawpattern.FindAllStringSubmatch(rest[group], -1)
			for _, drawmatch := range drawmatches {
				amount, err := strconv.Atoi(drawmatch[1])
				if err != nil {
					panic(err)
				}
				switch drawmatch[2] {
				case "red":
					draw.red = amount
				case "green":
					draw.green = amount
				case "blue":
					draw.blue = amount
				}
			}
			draws = append(draws, draw)
		}
		games = append(games, Game{id: id, draws: draws})
	}
	return games
}
