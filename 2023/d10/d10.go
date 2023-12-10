package d10

import (
	"log"
	"strings"
)

type Coord struct {
	r, c int
}

type Direction string

const (
	N Direction = "N"
	E           = "E"
	S           = "S"
	W           = "W"
	X           = "X"
)

var Moves = map[Direction]Coord{N: {-1, 0}, E: {0, 1}, S: {1, 0}, W: {0, -1}, X: {0, 0}}
var Cross = map[Direction]Direction{N: S, E: W, S: N, W: E, X: X}

var Tiles = map[string][]Direction{
	"|": {N, S},       // is a vertical pipe connecting north and south.
	"-": {W, E},       // is a horizontal pipe connecting east and west.
	"L": {N, E},       // is a 90-degree bend connecting north and east.
	"J": {N, W},       // is a 90-degree bend connecting north and west.
	"7": {S, W},       // is a 90-degree bend connecting south and west.
	"F": {S, E},       // is a 90-degree bend connecting south and east.
	".": {},           // is ground; there is no pipe in this tile.
	"S": {N, E, S, W}, // is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
}

func contains(s []Direction, e Direction) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

func travel(grid [][]string, start Coord, dir Direction) (dest Coord, next Direction) {
	if dir == X {
		return start, X
	}

	tile := grid[start.r][start.c]
	if !contains(Tiles[tile], dir) {
		return start, X
	}

	move := Moves[dir]
	dest = Coord{r: start.r + move.r, c: start.c + move.c}
	if dest.r < 0 || dest.r >= len(grid) || dest.c < 0 || dest.c >= len(grid[0]) {
		return start, X
	}

	tile = grid[dest.r][dest.c]
	if !contains(Tiles[tile], Cross[dir]) {
		return start, X
	}

	for _, maybe := range Tiles[tile] {
		if maybe != Cross[dir] {
			return dest, maybe
		}
	}
	return start, X
}

func SolvePart1(input string) (ans int) {
	grid, start := parse(input)

	for _, dir := range []Direction{N, E, S, W} {
		fast, slow := start, start
		fastd, slowd := dir, dir
		i := 0
		for {
			if i != 0 && fast == start {
				return i
			}

			slow, slowd = travel(grid, slow, slowd)
			fast, fastd = travel(grid, fast, fastd)
			fast, fastd = travel(grid, fast, fastd)
			if slowd == X || fastd == X {
				break
			}

			i++
		}
	}

	log.Fatal("no solution found")
	return
}

func SolvePart2(input string) (ans int) {
	return
}

func parse(input string) (grid [][]string, start Coord) {
	for i, line := range strings.Split(strings.TrimSpace(input), "\n") {
		row := make([]string, len(line))
		for j, c := range line {
			if c == 'S' {
				start = Coord{i, j}
			}
			row[j] = string(c)
		}
		grid = append(grid, row)
	}
	return grid, start
}
