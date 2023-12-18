package d18

import (
	"log"
	"regexp"
	"strconv"
	"strings"
)

type Direction int

const (
	U Direction = iota
	R
	D
	L
)

var Moves = map[Direction]Coord{
	U: {r: -1, c: 0},
	R: {r: 0, c: 1},
	D: {r: 1, c: 0},
	L: {r: 0, c: -1},
}
var StrMoves = map[string]Direction{"U": U, "R": R, "D": D, "L": L}

type Plan struct {
	dir  Direction
	dist int
}

type Coord struct {
	r, c int
}

func solve(input string, first bool) (ans int) {
	origin := Coord{0, 0}
	cur := origin
	path := []Coord{origin}

	for _, plan := range parse(input, first) {
		cur = Coord{cur.r + Moves[plan.dir].r*plan.dist, cur.c + Moves[plan.dir].c*plan.dist}
		path = append(path, cur)
	}

	return area(path)
}

func SolvePart1(input string) (ans int) {
	return solve(input, true)
}

func SolvePart2(input string) (ans int) {
	return solve(input, false)
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func area(coords []Coord) (ans int) {
	dets := 0
	edge := 0
	for i := 0; i < len(coords)-1; i++ {
		j := i + 1
		ri, ci := coords[i].r, coords[i].c
		rj, cj := coords[j].r, coords[j].c
		dets += ri*cj - rj*ci
		edge += abs(ri-rj) + abs(ci-cj)
	}
	return (abs(dets)+edge)/2 + 1
}

func parse(input string, first bool) (plans []Plan) {
	re := regexp.MustCompile(`([A-Z]) (\d+) \(#([0-9a-f]+)\)`)
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		match := re.FindStringSubmatch(line)
		plan := Plan{}
		if first {
			dir, ok := StrMoves[match[1]]
			if !ok {
				log.Fatalf("unexpected direction: %s", match[1])
			}
			dist, err := strconv.Atoi(match[2])
			if err != nil {
				log.Fatalf("failed to parse dist %s as int", match[1])
			}
			plan.dir = dir
			plan.dist = dist
		} else {
			dist, err := strconv.ParseInt(match[3][:5], 16, 32)
			if err != nil {
				log.Fatalf("failed to parse dist %s as int", match[1])
			}
			plan.dist = int(dist)

			dir, err := strconv.ParseInt(match[3][5:], 16, 32)
			if err != nil {
				log.Fatalf("failed to parse dir %s as int", match[1])
			}
			plan.dir = (Direction)(dir)
		}

		plans = append(plans, plan)
	}
	return plans
}
