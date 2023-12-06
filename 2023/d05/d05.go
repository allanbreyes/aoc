package d05

import (
	"math"
	"sort"
	"strconv"
	"strings"
)

type Interval struct {
	start int
	end   int
}

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
	seedValues, maps := parse(input)
	seeds := []Interval{}
	for i := 0; i < len(seedValues); i += 2 {
		seeds = append(seeds, Interval{start: seedValues[i], end: seedValues[i] + seedValues[i+1]})
	}
	locations := []Interval{}

	// TODO: interval tree would have been sooo much cleaner here!
	for _, seed := range seeds {
		queue := []Interval{seed}

		for _, m := range maps {
			resolved := []Interval{}

			for {
				if len(queue) == 0 {
					break
				}
				interval := queue[0]
				queue = queue[1:]

				mapped := false
				for _, mapping := range m {
					if interval.start >= mapping.end || interval.end <= mapping.start {
						// Interval is outside of mapping
						continue
					} else if interval.start >= mapping.start && interval.end <= mapping.end {
						// Interval is contained in mapping
						mapped = true
						new := Interval{start: interval.start + mapping.offset, end: interval.end + mapping.offset}
						resolved = append(resolved, new)
					} else if interval.start >= mapping.start && interval.end > mapping.end {
						// Lower interval is covered
						mapped = true
						new := Interval{start: interval.start + mapping.offset, end: mapping.end + mapping.offset}
						resolved = append(resolved, new)

						rest := Interval{start: mapping.end, end: interval.end}
						queue = append(queue, rest)
					} else if interval.start < mapping.start && interval.end <= mapping.end {
						// Upper interval is covered
						mapped = true
						new := Interval{start: mapping.start + mapping.offset, end: interval.end + mapping.offset}
						resolved = append(resolved, new)

						rest := Interval{start: interval.start, end: mapping.start}
						queue = append(queue, rest)
					} else {
						// Middle of interval is covered
						mapped = true
						new := Interval{start: mapping.start + mapping.offset, end: mapping.end + mapping.offset}
						resolved = append(resolved, new)

						rest := []Interval{
							{start: interval.start, end: mapping.start},
							{start: mapping.end, end: interval.end},
						}
						queue = append(queue, rest...)
					}
					break
				}

				if !mapped {
					resolved = append(resolved, interval)
				}
			}

			queue = resolved
		}

		locations = append(locations, queue...)
	}

	min := math.MaxInt
	for _, location := range locations {
		min = int(math.Min(float64(min), float64(location.start)))
	}

	return min

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

			sort.Slice(m, func(i, j int) bool {
				return m[i].start < m[j].start
			})
			maps = append(maps, m)
		}
	}

	return seeds, maps
}
