package d21

import (
	"strings"
)

type Grid []string
type Pos struct {
	r, c int
}
type PosSet map[Pos]struct{}
type WalkCacheKey struct {
	steps int
	src   Pos
}
type WalkCache map[WalkCacheKey]PosSet

func SolvePart1(input string) (ans int) {
	grid, start := parse(input)
	cache := make(WalkCache)
	dests := walk(64, start, grid, cache)
	return len(dests)
}

func SolvePart2(input string) (ans int) {
	return
}

func neighbors(pos Pos, grid Grid) (neighbors []Pos) {
	for _, dir := range []Pos{{-1, 0}, {1, 0}, {0, -1}, {0, 1}} {
		r, c := pos.r+dir.r, pos.c+dir.c
		if r < 0 || r >= len(grid) || c < 0 || c >= len(grid[r]) || grid[r][c] == '#' {
			continue
		}
		neighbors = append(neighbors, Pos{r, c})
	}
	return
}

func walk(steps int, src Pos, grid Grid, cache WalkCache) (dests PosSet) {
	dests = make(PosSet)
	if steps == 0 {
		dests[src] = struct{}{}
		return
	} else if dests, ok := cache[WalkCacheKey{steps, src}]; ok {
		return dests
	}
	for _, neighbor := range neighbors(src, grid) {
		for dest := range walk(steps-1, neighbor, grid, cache) {
			dests[dest] = struct{}{}
		}
	}
	cache[WalkCacheKey{steps, src}] = dests
	return
}

func parse(input string) (grid Grid, start Pos) {
	grid = append(grid, strings.Split(input, "\n")...)
	for r, row := range grid {
		for c, char := range row {
			if char == 'S' {
				start = Pos{r, c}
			}
		}
	}
	return grid, start
}
