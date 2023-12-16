package d16

import (
	"log"
	"strings"
)

type Coord struct {
	r, c int
}

type Direction int

const (
	N Direction = iota
	E
	S
	W
)

var Moves = map[Direction]Coord{N: {-1, 0}, E: {0, 1}, S: {1, 0}, W: {0, -1}}

type Beam struct {
	r, c int
	h    Direction
}

func SolvePart1(input string) (ans int) {
	grid := parse(input)
	return simulate(grid, Beam{0, -1, E})
}

func SolvePart2(input string) (most int) {
	grid := parse(input)
	m, n := len(grid), len(grid[0])

	starts := []Beam{}
	for r := 0; r < m; r++ {
		starts = append(starts, Beam{r, -1, E}, Beam{r, n, W})
	}
	for c := 0; c < n; c++ {
		starts = append(starts, Beam{-1, c, S}, Beam{m, c, N})
	}

	for _, start := range starts {
		lit := simulate(grid, start)
		if lit > most {
			most = lit
		}
	}

	return most
}

func simulate(grid []string, start Beam) (ans int) {
	beams := []Beam{start}
	lit := map[Coord]bool{}
	seen := map[Beam]bool{}

	for {
		if len(beams) == 0 {
			break
		}

		next := []Beam{}
		for _, beam := range beams {
			beam, ok := move(beam, grid)
			if !ok || seen[beam] {
				continue
			}
			lit[Coord{beam.r, beam.c}] = true
			seen[beam] = true

			next = append(next, reflect(beam, grid)...)
		}
		beams = next
	}

	return len(lit)
}

func move(beam Beam, grid []string) (next Beam, ok bool) {
	v := Moves[beam.h]
	m, n := len(grid), len(grid[0])
	r, c := beam.r+v.r, beam.c+v.c
	h := beam.h

	if r < 0 || r >= m || c < 0 || c >= n {
		return Beam{}, false
	}
	return Beam{r, c, h}, true
}

func reflect(beam Beam, grid []string) (new []Beam) {
	r, c := beam.r, beam.c
	h := beam.h
	cw := (h + 1) % 4
	ccw := (h + 3) % 4

	switch grid[r][c] {
	case '.':
	case '/':
		if h == N || h == S {
			beam.h = cw
		} else if h == E || h == W {
			beam.h = ccw
		}
	case '\\':
		if h == N || h == S {
			beam.h = ccw
		} else if h == E || h == W {
			beam.h = cw
		}
	case '|':
		if h == E || h == W {
			return []Beam{
				{r, c, cw},
				{r, c, ccw},
			}
		}
	case '-':
		if h == N || h == S {
			return []Beam{
				{r, c, cw},
				{r, c, ccw},
			}
		}
	default:
		log.Fatalf("invalid value: %c", grid[r][c])
	}

	return []Beam{beam}
}

func parse(input string) []string {
	return strings.Split(strings.TrimSpace(input), "\n")
}
