package d17

import (
	"fmt"
	"log"
	"strconv"
	"strings"

	// NOTE: it's Sunday, and I'm too lazy to re-implement A*
	"github.com/beefsack/go-astar"
)

var (
	// Grid world
	grid      [][]int
	positions map[Pos]*Pos

	// Crucible physics constants, i.e. min/max streak
	mins int
	maxs int
)

type Direction int

const (
	N Direction = iota
	E
	S
	W
	U // Upright, unknown, etc.
)

var Moves = map[Direction]Pos{
	N: {r: -1, c: 0},
	E: {r: 0, c: 1},
	S: {r: 1, c: 0},
	W: {r: 0, c: -1},
}

type Pos struct {
	// Row and column coordinates
	r, c int

	// Heading
	h Direction

	// Streak in current heading
	s int
}

func pos(r, c int, h Direction, s int) *Pos {
	p := Pos{r: r, c: c, h: h, s: s}
	if ref, ok := positions[p]; ok {
		return ref
	}
	ref := &p
	positions[p] = ref
	return ref
}

func (p *Pos) PathNeighbors() (next []astar.Pather) {
	m, n := len(grid), len(grid[0])

	// Start
	if p.r == 0 && p.c == 0 && p.h == U {
		next = append(next, pos(0, 1, E, 1))
		next = append(next, pos(1, 0, S, 1))
	}

	// Goal
	if p.r == m-1 && p.c == n-1 && p.h != U {
		next = append(next, pos(p.r, p.c, U, 0))
	}

	// North
	if p.r > 0 && p.h != S {
		if p.h == N {
			if p.s < maxs {
				next = append(next, pos(p.r-1, p.c, N, p.s+1))
			}
		} else if p.s >= mins {
			next = append(next, pos(p.r-1, p.c, N, 1))
		}
	}

	// East
	if p.c < n-1 && p.h != W {
		if p.h == E {
			if p.s < maxs {
				next = append(next, pos(p.r, p.c+1, E, p.s+1))
			}
		} else if p.s >= mins {
			next = append(next, pos(p.r, p.c+1, E, 1))
		}
	}

	// South
	if p.r < m-1 && p.h != N {
		if p.h == S {
			if p.s < maxs {
				next = append(next, pos(p.r+1, p.c, S, p.s+1))
			}
		} else if p.s >= mins {
			next = append(next, pos(p.r+1, p.c, S, 1))
		}
	}

	// West
	if p.c > 0 && p.h != E {
		if p.h == W {
			if p.s < maxs {
				next = append(next, pos(p.r, p.c-1, W, p.s+1))
			}
		} else if p.s >= mins {
			next = append(next, pos(p.r, p.c-1, W, 1))
		}
	}

	return next
}

func (p *Pos) PathNeighborCost(to astar.Pather) (cost float64) {
	m, n := len(grid), len(grid[0])
	r, c := to.(*Pos).r, to.(*Pos).c
	if r == m-1 && c == n-1 && to.(*Pos).h != U {
		// No cost to enter goal state
		return 0
	}
	return float64(grid[r][c])
}

func (p *Pos) PathEstimatedCost(to astar.Pather) (cost float64) {
	// Manhattan distance to goal (bottom-rightmost corner)
	m, n := len(grid), len(grid[0])
	return float64(m-to.(*Pos).r-1) + float64(n-to.(*Pos).c-1)
}

func draw(path []astar.Pather) {
	fmt.Println("=== length:", len(path), "===")
	sketch := make([][]string, len(grid))
	m, n := len(grid), len(grid[0])
	for i := 0; i < m; i++ {
		sketch[i] = make([]string, n)
		for j := 0; j < n; j++ {
			sketch[i][j] = strconv.Itoa(grid[i][j])
		}
	}
	for _, p := range path {
		r, c := p.(*Pos).r, p.(*Pos).c

		sketch[r][c] = fmt.Sprintf("\033[0;31m%d\033[0m", grid[r][c])
	}

	for _, row := range sketch {
		for _, cell := range row {
			fmt.Print(cell)
		}
		fmt.Print("\n")
	}
}

func init() {
	positions = make(map[Pos]*Pos)
}

func solve() int {
	m, n := len(grid), len(grid[0])

	start := pos(0, 0, U, 0)
	goal := pos(m-1, n-1, U, 0)

	path, dist, found := astar.Path(start, goal)
	if !found {
		log.Fatalf("no path found")
	}
	draw(path)
	return int(dist)
}

func SolvePart1(input string) (ans int) {
	mins, maxs = 0, 3
	parse(input)
	return solve()
}

func SolvePart2(input string) (ans int) {
	mins, maxs = 4, 10
	parse(input)
	return solve()
}

func parse(input string) [][]int {
	grid = [][]int{}
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		row := []int{}
		for _, char := range line {
			num, err := strconv.Atoi(string(char))
			if err != nil {
				log.Fatalf("failed to parse %s as int", string(char))
			}
			row = append(row, num)
		}
		grid = append(grid, row)
	}

	return grid
}
