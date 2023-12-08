package d07

import (
	"math"
	"sort"
	"strconv"
	"strings"
)

var cardMap1 = map[string]int{
	"2": 2,
	"3": 3,
	"4": 4,
	"5": 5,
	"6": 6,
	"7": 7,
	"8": 8,
	"9": 9,
	"T": 10,
	"J": 11,
	"Q": 12,
	"K": 13,
	"A": 14,
}

var cardMap2 = map[string]int{
	"J": 1,
	"2": 2,
	"3": 3,
	"4": 4,
	"5": 5,
	"6": 6,
	"7": 7,
	"8": 8,
	"9": 9,
	"T": 10,
	"Q": 11,
	"K": 12,
	"A": 13,
}

type Hand struct {
	cards []int
	bid   int
}

func SolvePart1(input string) int {
	hands := parse(input, cardMap1)
	sort.Slice(hands, func(i, j int) bool {
		return score1(hands[i]) < score1(hands[j])
	})

	total := 0
	for i, hand := range hands {
		total += hand.bid * (i + 1)
	}

	return total
}

func count(values []int) map[int]int {
	counter := map[int]int{}
	for _, value := range values {
		if _, ok := counter[value]; !ok {
			counter[value] = 1
		} else {
			counter[value]++
		}
	}
	return counter
}

func score1(hand Hand) int {
	value := 0

	// Count and group
	counter := count(hand.cards)
	groups := map[int]int{
		1: 0,
		2: 0,
		3: 0,
		4: 0,
		5: 0,
	}
	for _, count := range counter {
		groups[count]++
	}

	// Calculate base value
	base := int(math.Pow(100, 5))
	if groups[5] == 1 {
		// Five of a kind
		value += base * 7
	} else if groups[4] == 1 {
		// Four of a kind
		value += base * 6
	} else if groups[3] == 1 && groups[2] == 1 {
		// Full house
		value += base * 5
	} else if groups[3] == 1 {
		// Three of a kind
		value += base * 4
	} else if groups[2] == 2 {
		// Two pair
		value += base * 3
	} else if groups[2] == 1 {
		// One pair
		value += base * 2
	} else {
		// High card
		value += base
	}

	// Add individual card values
	for i, card := range hand.cards {
		j := len(hand.cards) - i - 1
		value += card * int(math.Pow(100, float64(j)))
	}

	return value
}

func SolvePart2(input string) int {
	hands := parse(input, cardMap2)
	sort.Slice(hands, func(i, j int) bool {
		return score2(hands[i]) < score2(hands[j])
	})

	total := 0
	for i, hand := range hands {
		total += hand.bid * (i + 1)
	}

	return total
}

func score2(hand Hand) int {
	value := 0

	// Count and return early original algorithm if no jokers
	counter := count(hand.cards)
	if _, ok := counter[1]; !ok {
		return score1(hand)
	}
	groups := map[int]int{
		0: 0,
		1: 0,
		2: 0,
		3: 0,
		4: 0,
		5: 0,
	}
	for n, count := range counter {
		if n == 1 {
			continue
		}
		groups[count]++
	}
	dof := counter[1]

	// NOTE: we could probably do some integer linear programming here with
	// constraints, but let's just hand-code the best cases.
	base := int(math.Pow(100, 5))
	if groups[5-dof] == 1 || dof >= 4 {
		// Five of a kind
		value += base * 7
	} else if groups[4] == 1 || groups[4-dof] == 1 || dof >= 3 {
		// Four of a kind
		value += base * 6
	} else if (groups[3] == 1 && groups[2] == 1) || (groups[2]+dof == 3) {
		// Full house
		value += base * 5
	} else if groups[3] == 1 || groups[3-dof] >= 1 || dof == 2 {
		// Three of a kind
		value += base * 4
	} else if groups[2] == 2 || groups[2-dof] == 1 {
		// Two pair
		value += base * 3
	} else if groups[2]+dof == 1 {
		// One pair
		value += base * 2
	} else {
		// High card
		value += base
	}

	// Add individual card values
	for i, card := range hand.cards {
		j := len(hand.cards) - i - 1
		value += card * int(math.Pow(100, float64(j)))
	}

	return value
}

func parse(input string, cardMap map[string]int) []Hand {
	hands := []Hand{}
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		parts := strings.Split(line, " ")
		cards := []int{}
		for _, card := range strings.Split(parts[0], "") {
			cards = append(cards, cardMap[card[:1]])
		}
		bid, _ := strconv.Atoi(parts[1])
		hands = append(hands, Hand{cards, bid})
	}
	return hands
}
