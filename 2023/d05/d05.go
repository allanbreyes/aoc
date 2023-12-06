package d05

import (
	"math"
	"sort"
	"strconv"
	"strings"
)

type Mapping struct {
	start  int
	end    int
	offset int
}

func SolvePart1(input string) int {
	seeds, maps := parse(input)
	locations := []int{}

	for _, seed := range seeds {
		value := seed

	Map:
		for _, m := range maps {
			for _, mapping := range m {
				if mapping.start <= value && value < mapping.end {
					new := value + mapping.offset
					value = new
					continue Map
				}
			}
		}

		locations = append(locations, value)
	}

	min := math.MaxInt
	for _, location := range locations {
		min = int(math.Min(float64(min), float64(location)))
	}
	return min
}

func SolvePart2(input string) int {
	return -1
}

func parse(input string) (seeds []int, maps [][]Mapping) {
	seeds = []int{}
	maps = [][]Mapping{}

	stanzas := strings.Split(input, "\n\n")
	for _, stanza := range stanzas {
		chunks := strings.Split(stanza, ":")
		label := chunks[0]
		body := strings.Split(strings.TrimSpace(chunks[1]), "\n")

		if label == "seeds" {
			for _, seed := range strings.Split(body[0], " ") {
				seed, _ := strconv.Atoi(seed)
				seeds = append(seeds, seed)
			}
		} else {
			m := []Mapping{}
			for _, line := range body {
				row := []int{}
				for _, number := range strings.Split(line, " ") {
					number, _ := strconv.Atoi(number)
					row = append(row, number)
				}

				mapping := Mapping{
					start:  row[1],
					end:    row[1] + row[2],
					offset: row[0] - row[1],
				}
				m = append(m, mapping)
			}

			// TODO: use a more efficient lookup data structure, e.g. tree
			sort.Slice(m, func(i, j int) bool {
				return m[i].start < m[j].start
			})
			maps = append(maps, m)
		}
	}

	return seeds, maps
}
