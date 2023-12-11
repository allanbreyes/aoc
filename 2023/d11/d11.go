package d11

import (
	"math"
	"sort"
	"strings"
)

type Coord struct {
	r, c int
}

func expand(coords []Coord, factor int) (new []Coord) {
	// Expand rows
	acc := 0
	lastrow := coords[len(coords)-1].r
	tmp := make([]Coord, len(coords))
	for r := 0; r <= lastrow; r++ {
		i := sort.Search(len(coords), func(i int) bool { return coords[i].r >= r })
		if coords[i].r != r {
			acc += factor - 1
			continue
		}

		for j := i; j < len(coords); j++ {
			if coords[j].r != r {
				break
			}
			tmp[j] = Coord{r + acc, coords[j].c}
		}
	}
	coords = tmp

	// Expand cols
	acc = 0
	sort.Slice(coords, func(i, j int) bool { return coords[i].c < coords[j].c })
	lastcol := coords[len(coords)-1].c
	new = make([]Coord, len(coords))
	for c := 0; c <= lastcol; c++ {
		i := sort.Search(len(coords), func(i int) bool { return coords[i].c >= c })
		if coords[i].c != c {
			acc += factor - 1
			continue
		}

		for j := i; j < len(coords); j++ {
			if coords[j].c != c {
				break
			}
			new[j] = Coord{coords[j].r, c + acc}
		}
	}

	// Get back into original order
	sort.Slice(new, func(i, j int) bool { return new[i].r < new[j].r })
	return new
}

func getDistances(coords []Coord) (sum int) {
	for i, a := range coords {
		for _, b := range coords[i+1:] {
			sum += int(math.Abs(float64(a.r-b.r)) + math.Abs(float64(a.c-b.c)))
		}
	}
	return
}

func Solve(input string, factor int) (ans int) {
	coords := parse(input)
	expanded := expand(coords, factor)
	return getDistances(expanded)
}

func SolvePart1(input string) (ans int) {
	return Solve(input, 2)
}

func SolvePart2(input string) (ans int) {
	return Solve(input, 1000000)
}

// Return a sparse list of coordinates of galaxies
func parse(input string) (list []Coord) {
	for r, row := range strings.Split(strings.TrimSpace(input), "\n") {
		for c, cell := range row {
			if cell == '#' {
				list = append(list, Coord{r, c})
			}
		}
	}
	return
}
