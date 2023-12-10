package d10

import (
	"fmt"
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

const (
	Empty = iota
	Pipe
	Outside
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

func loop(grid [][]string, start Coord, dir Direction) (coords []Coord, ok bool) {
	fast, slow := start, start
	fastd, slowd := dir, dir
	for i := 0; i < len(grid)*len(grid[0]); i++ {
		if i != 0 && fast == start {
			return coords, true
		}

		slow, slowd = travel(grid, slow, slowd)
		fast, fastd = travel(grid, fast, fastd)
		coords = append(coords, fast)
		fast, fastd = travel(grid, fast, fastd)
		coords = append(coords, fast)
		if slowd == X || fastd == X {
			break
		}
	}

	return []Coord{}, false
}

func pad(grid [][]string) (new [][]string) {
	colsize := len(grid[0])
	emptyrow := make([]string, colsize)
	for i := range emptyrow {
		emptyrow[i] = "."
	}
	new = append(new, emptyrow)
	new = append(new, grid...)
	new = append(new, emptyrow)

	for i := range new {
		new[i] = append([]string{"."}, new[i]...)
		new[i] = append(new[i], ".")
	}

	return new
}

func expand(grid [][]string, coords []Coord) (new [][]int) {
	x := 3 // Expand to 3x3
	rowsize := len(grid) * x
	colsize := len(grid[0]) * x
	new = make([][]int, rowsize)
	for ni := range new {
		new[ni] = make([]int, colsize)
	}

	for _, coord := range coords {
		ni := coord.r * x
		nj := coord.c * x
		tile := grid[coord.r][coord.c]

		nw, nn, ne := 0, 0, 0
		ww, ct, ee := 0, 1, 0
		sw, ss, se := 0, 0, 0

		switch tile {
		case "|":
			nn, ss = 1, 1
		case "-":
			ww, ee = 1, 1
		case "L":
			nn, ee = 1, 1
		case "J":
			nn, ww = 1, 1
		case "7":
			ww, ss = 1, 1
		case "F":
			ee, ss = 1, 1
		// NOTE: this might cause some issues around the start point
		case "S":
			nn, ee, ss, ww = 1, 1, 1, 1
		}

		new[ni][nj] = nw
		new[ni][nj+1] = nn
		new[ni][nj+2] = ne
		new[ni+1][nj] = ww
		new[ni+1][nj+1] = ct
		new[ni+1][nj+2] = ee
		new[ni+2][nj] = sw
		new[ni+2][nj+1] = ss
		new[ni+2][nj+2] = se
	}

	return new
}

func contract(fill [][]int) (new [][]int) {
	x := 3 // Contract from 3x3
	rowsize := len(fill) / x
	colsize := len(fill[0]) / x
	new = make([][]int, rowsize)
	for ni := range new {
		new[ni] = make([]int, colsize)
	}

	for i := 0; i < len(fill); i += x {
		for j := 0; j < len(fill[0]); j += x {
			ct := fill[i+1][j+1]
			new[i/x][j/x] = ct
		}
	}

	return new
}

func flood(fill [][]int, cursor Coord) {
	if cursor.r < 0 || cursor.r >= len(fill) || cursor.c < 0 || cursor.c >= len(fill[0]) {
		return
	}
	if fill[cursor.r][cursor.c] != Empty {
		return
	}
	fill[cursor.r][cursor.c] = Outside

	for _, dir := range []Direction{N, E, S, W} {
		flood(fill, Coord{cursor.r + Moves[dir].r, cursor.c + Moves[dir].c})
	}
}

func SolvePart1(input string) (ans int) {
	grid, start := parse(input)

	for _, dir := range []Direction{N, E, S, W} {
		coords, ok := loop(grid, start, dir)
		if ok {
			return len(coords) / 2
		}
	}

	log.Fatal("no solution found")
	return
}

func SolvePart2(input string) (ans int) {
	// Pad grid
	grid, start := parse(input)
	grid = pad(grid)
	start = Coord{start.r + 1, start.c + 1}

	// Find loop
	coords := []Coord{}
	ok := false
	for _, dir := range []Direction{N, E, S, W} {
		coords, ok = loop(grid, start, dir)
		if ok {
			break
		}
	}
	if !ok {
		log.Fatal("no loop found")
	}

	// Initialize fill map
	fill := expand(grid, coords)

	// Flood fill and contract
	flood(fill, Coord{0, 0})
	fill = contract(fill)

	// Count and draw
	for i, row := range fill {
		for j, cell := range row {
			switch cell {
			case Empty:
				{
					ans++
					fmt.Print("\033[0;31mI\033[0m")
				}
			case Pipe:
				fmt.Print(grid[i][j])
			case Outside:
				fmt.Print(" ")
			default:
				log.Fatal("unexpected cell")
			}
		}
		fmt.Print("\n")
	}
	return ans
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
