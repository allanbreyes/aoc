package d21

import (
	"log"
	"strings"
)

type Grid []string
type Pos struct {
	r, c int
	R, C int
}
type PosSet map[Pos]struct{}
type Point struct {
	x, y int
}

func SolvePart1(input string) (ans int) {
	return Solve(input, 64, false)
}

func SolvePart2(input string) (ans int) {
	return Solve(input, 26501365, true)
}

func Solve(input string, steps int, tiled bool) (ans int) {
	grid, start := parse(input)
	_, n := len(grid), len(grid[0])
	points := []Point{}
	next := PosSet{start: struct{}{}}
	for s := 0; s <= steps; s++ {
		if s == steps {
			return len(next)
		} else if s%n == n/2 {
			// Accumulate points for curve-fitting. Note that this does not
			// generalize and is specific to similarly-shaped inputs with an
			// open border, as well as the number of steps.
			points = append(points, Point{len(points), len(next)})
			if len(points) >= 3 {
				break
			}
		}

		queue := next
		next = make(PosSet)
		for pos := range queue {
			for _, neighbor := range neighbors(pos, grid, tiled) {
				next[neighbor] = struct{}{}
			}
		}
	}
	return lagrange3(steps/n, points)
}

func lagrange3(x int, p []Point) int {
	// See: https://brilliant.org/wiki/lagrange-interpolation/
	if len(p) != 3 {
		log.Fatalf("expected 3 points, got %d", len(p))
	}
	x1, x2, x3 := p[0].x, p[1].x, p[2].x
	y1, y2, y3 := p[0].y, p[1].y, p[2].y
	y := ((x - x2) * (x - x3) * y1) / ((x1 - x2) * (x1 - x3))
	y += ((x - x1) * (x - x3) * y2) / ((x2 - x1) * (x2 - x3))
	y += ((x - x1) * (x - x2) * y3) / ((x3 - x1) * (x3 - x2))
	return y
}

func neighbors(pos Pos, grid Grid, tiled bool) (neighbors []Pos) {
	m, n := len(grid), len(grid[0])
	for _, dir := range []Pos{{-1, 0, 0, 0}, {1, 0, 0, 0}, {0, -1, 0, 0}, {0, 1, 0, 0}} {
		if tiled {
			r, c := pos.r+dir.r, pos.c+dir.c
			R, C := pos.R+dir.R, pos.C+dir.C
			if r < 0 {
				r = m - 1
				R = pos.R - 1
			} else if r >= m {
				r = 0
				R = pos.R + 1
			} else if c < 0 {
				c = n - 1
				C = pos.C - 1
			} else if c >= n {
				c = 0
				C = pos.C + 1
			}

			if grid[r][c] == '#' {
				continue
			}
			neighbors = append(neighbors, Pos{r, c, R, C})
		} else {
			r, c := pos.r+dir.r, pos.c+dir.c
			if r < 0 || r >= len(grid) || c < 0 || c >= len(grid[r]) || grid[r][c] == '#' {
				continue
			}
			neighbors = append(neighbors, Pos{r, c, 0, 0})
		}
	}
	return
}

func parse(input string) (grid Grid, start Pos) {
	grid = append(grid, strings.Split(strings.TrimSpace(input), "\n")...)
	for r, row := range grid {
		for c, char := range row {
			if char == 'S' {
				start = Pos{r, c, 0, 0}
			}
		}
	}
	return grid, start
}
