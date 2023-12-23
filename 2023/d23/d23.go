package d23

import (
	"fmt"
	"log"
	"strings"
)

type Grid []string
type Pos struct {
	r, c int
}

type PosSet map[Pos]struct{}

func (ps PosSet) add(p Pos) {
	ps[p] = struct{}{}
}

func (ps PosSet) has(p Pos) bool {
	_, ok := ps[p]
	return ok
}

func (ps PosSet) clone() PosSet {
	clone := make(PosSet)
	for k, v := range ps {
		clone[k] = v
	}
	return clone
}

type Option struct {
	pos  Pos
	dist int
}
type Graph map[Pos][]Option

var Slopes = map[rune]Pos{
	'^': {-1, 0},
	'>': {0, 1},
	'v': {1, 0},
	'<': {0, -1},
}

func SolvePart1(input string) (ans int) {
	return Solve(input, true)
}

func SolvePart2(input string) (ans int) {
	return Solve(input, false)
}

func Solve(input string, slopes bool) (ans int) {
	grid := parse(input)
	start, end := terminals(grid)
	graph := build(grid, start, end, slopes)
	if !slopes {
		draw(grid, graph)
	}
	ans, terminates := search(start, end, PosSet{start: struct{}{}}, graph, 0, 0)
	if !terminates {
		log.Fatalf("no solution")
	}
	return ans
}

func search(pos Pos, goal Pos, seen PosSet, graph Graph, dist int, longest int) (res int, terminates bool) {
	// TODO: it's still slow! Maybe try pruning parts of the graph that are
	// known dead ends and/or caching?
	if pos == goal {
		return max(longest, dist), true
	}
	for _, option := range graph[pos] {
		if seen.has(option.pos) {
			continue
		}

		nextseen := seen.clone()
		nextseen.add(option.pos)

		dist, terminate := search(option.pos, goal, nextseen, graph, dist+option.dist, longest)
		if terminate {
			longest = max(longest, dist)
			terminates = true
		}
	}

	return longest, terminates
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func neighbors(pos Pos, grid Grid, slopes bool) (neighbors []Pos) {
	deltas := []Pos{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
	if slopes {
		allowed, sloped := Slopes[rune(grid[pos.r][pos.c])]
		if sloped {
			deltas = []Pos{allowed}
		}
	}

	for _, delta := range deltas {
		r, c := pos.r+delta.r, pos.c+delta.c
		if r < 0 || r >= len(grid) || c < 0 || c >= len(grid[0]) || grid[r][c] == '#' {
			continue
		}
		neighbors = append(neighbors, Pos{r, c})
	}
	return neighbors
}

func terminals(grid Grid) (start Pos, end Pos) {
	m := len(grid)
	for i, row := range grid {
		if i == 0 || i == m-1 {
			for j, char := range row {
				if char == '.' {
					if i == 0 {
						start = Pos{i, j}
					} else if i == m-1 {
						end = Pos{i, j}
					}
					break
				}
			}
		}
	}
	return
}

func chokepoints(grid Grid) (chokepoints PosSet) {
	chokepoints = make(PosSet)
	for r, row := range grid {
		for c, char := range row {
			if char == '#' {
				continue
			}
			if len(neighbors(Pos{r, c}, grid, false)) > 2 {
				chokepoints[Pos{r, c}] = struct{}{}
			}
		}
	}
	return chokepoints
}

func build(grid Grid, start Pos, end Pos, slopes bool) Graph {
	cps := chokepoints(grid)
	cps.add(start)
	cps.add(end)

	graph := make(Graph)
	for cp := range cps {
		queue := []Pos{cp}
		seen := make(PosSet)
		seen.add(cp)
		dist := 0

		for len(queue) > 0 {
			dist++
			todo := []Pos{}

			for _, pos := range queue {
				for _, next := range neighbors(pos, grid, slopes) {
					if seen.has(next) {
						continue
					}

					seen.add(next)
					if cps.has(next) {
						graph[cp] = append(graph[cp], Option{next, dist})
					} else {
						todo = append(todo, next)
					}
				}
			}
			queue = todo
		}
	}
	return graph
}

func draw(grid Grid, graph Graph) {
	for r, row := range grid {
		for c, char := range row {
			if graph[Pos{r, c}] != nil {
				fmt.Printf("\033[31m%2d\033[0m", len(graph[Pos{r, c}]))
			} else if strings.ContainsRune("^>v<", char) {
				fmt.Printf("\033[34m%2s\033[0m", string(char))
			} else {
				fmt.Printf("%2s", string(char))
			}
		}
		fmt.Println()
	}
}

func parse(input string) Grid {
	return strings.Split(strings.TrimSpace(input), "\n")
}
