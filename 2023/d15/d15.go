package d15

import (
	"log"
	"strconv"
	"strings"
)

func SolvePart1(input string) (sum int) {
	for _, term := range parse(input) {
		sum += Hash(term)
	}
	return
}

func SolvePart2(input string) (ans int) {
	boxes := make(map[int][]Lens)
	for i := 0; i < 256; i++ {
		boxes[i] = []Lens{}
	}

	// Fill in boxes
	for _, term := range parse(input) {
		if strings.Contains(term, "=") {
			lens := parseLens(term)

			found := false
			for j := 0; j < len(boxes[lens.hash]); j++ {
				if boxes[lens.hash][j].label == lens.label {
					boxes[lens.hash][j].focal = lens.focal
					found = true
					break
				}
			}

			if !found {
				boxes[lens.hash] = append(boxes[lens.hash], lens)
			}
		} else if strings.Contains(term, "-") {
			label := strings.Replace(term, "-", "", 1)
			hash := Hash(label)
			for j := 0; j < len(boxes[hash]); j++ {
				if boxes[hash][j].label == label {
					boxes[hash] = append(boxes[hash][:j], boxes[hash][j+1:]...)
					break
				}
			}
		} else {
			log.Fatalf("unexpected term: %s", term)
		}

	}

	// Calculate focusing power
	for i := 0; i < len(boxes); i++ {
		box := boxes[i]
		for j := 0; j < len(box); j++ {
			ans += (i+1) * (j+1) * box[j].focal
		}
	}
	return ans
}

func Hash(input string) (hash int) {
	for _, c := range input {
		hash += int(c)
		hash *= 17
		hash %= 256
	}
	return hash
}

type Lens struct {
	label string
	hash int
	focal int 
}

func parseLens(term string) (lens Lens) {
	parts := strings.Split(term, "=")
	lens.label = parts[0]
	lens.hash = Hash(lens.label)
	fl, ok := strconv.Atoi(parts[1])
	if ok != nil {
		log.Fatalf("unexpected focal length: %s", parts[1])
	}
	lens.focal = fl
	return
}

func parse(input string) []string {
	return strings.Split(strings.TrimSpace(input), ",")
}
