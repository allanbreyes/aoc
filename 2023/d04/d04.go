package d04

import (
	"regexp"
	"strconv"
	"strings"
)

type Card struct {
	id      int
	winning []int
	chosen  []int
}

func SolvePart1(input string) int {
	cards := parse(input)
	sum := 0
	for _, card := range cards {
		winning := map[int]struct{}{}
		for _, number := range card.winning {
			winning[number] = struct{}{}
		}

		score := 0
		for _, number := range card.chosen {
			if _, ok := winning[number]; ok {
				if score == 0 {
					score += 1
				} else {
					score *= 2
				}
			}
		}

		sum += score
	}
	return sum
}

func SolvePart2(input string) int {
	cards := parse(input)
	scores := map[int]int{}
	for _, card := range cards {
		winning := map[int]struct{}{}
		for _, number := range card.winning {
			winning[number] = struct{}{}
		}

		score := 0
		for _, number := range card.chosen {
			if _, ok := winning[number]; ok {
				score += 1
			}
		}
		scores[card.id] = score
	}

	sum := 0
	for _, card := range cards {
		sum += count(card.id, scores)
	}

	return sum
}

func count(id int, scores map[int]int) int {
	score := scores[id]
	copies := 1
	for i := id + 1; i <= id+score && i <= len(scores); i++ {
		copies += count(i, scores)
	}
	return copies
}

func parse(input string) []Card {
	cards := []Card{}
	re := regexp.MustCompile(`Card\s+(\d+): ([\d\s]+) \| ([\d\s]+)`)
	matches := re.FindAllStringSubmatch(input, -1)
	for _, match := range matches {
		id, _ := strconv.Atoi(match[1])

		winning := []int{}
		for _, number := range strings.Fields(match[2]) {
			n, _ := strconv.Atoi(number)
			winning = append(winning, n)
		}

		chosen := []int{}
		for _, number := range strings.Fields(match[3]) {
			n, _ := strconv.Atoi(number)
			chosen = append(chosen, n)
		}

		cards = append(cards, Card{
			id:      id,
			winning: winning,
			chosen:  chosen,
		})
	}
	return cards
}
