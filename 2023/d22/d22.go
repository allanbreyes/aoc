package d22

import (
	"log"
	"sort"
	"strconv"
	"strings"
)

type Pos struct {
	x, y, z int
}

type Pos2D struct {
	x, y int
}

type PeakMap map[Pos2D]int

type Brick struct {
	a, b Pos
}

// Give the peak height relevant to and from the POV of the brick
func (p PeakMap) from(brick Brick) (peak int) {
	for x := brick.a.x; x <= brick.b.x; x++ {
		for y := brick.a.y; y <= brick.b.y; y++ {
			peak = max(peak, p[Pos2D{x, y}])
		}
	}
	return peak
}

func SolvePart1(input string) (ans int) {
	ans, _ = Solve(input)
	return
}

func SolvePart2(input string) (ans int) {
	_, ans = Solve(input)
	return
}

func Solve(input string) (disintegratable, total int) {
	bricks := parse(input)
	bricks, _ = settle(bricks)
	for i := range bricks {
		clone := make([]Brick, len(bricks))
		copy(clone, bricks)
		without := append(clone[:i], clone[i+1:]...)
		_, drops := settle(without)
		if drops == 0 {
			disintegratable++
		} else {
			total += drops
		}
	}
	return disintegratable, total
}

func max(a, b int) (m int) {
	if a > b {
		return a
	}
	return b
}

func settle(bricks []Brick) (settled []Brick, drops int) {
	// Sort by z so we can drop one brick at a time
	sort.Slice(bricks, func(i, j int) bool {
		return bricks[i].a.z < bricks[j].a.z
	})

	peaks := PeakMap{}
	for _, brick := range bricks {
		// Drop the brick
		next, dropped := drop(brick, peaks)
		if dropped {
			drops++
		}
		settled = append(settled, next)

		// Update peaks map
		for x := next.a.x; x <= next.b.x; x++ {
			for y := next.a.y; y <= next.b.y; y++ {
				peaks[Pos2D{x, y}] = max(next.b.z, peaks[Pos2D{x, y}])
			}
		}
	}

	return settled, drops
}

func drop(brick Brick, peaks PeakMap) (new Brick, dropped bool) {
	peak := peaks.from(brick)
	dist := max(brick.a.z-peak-1, 0)
	new = Brick{
		a: Pos{brick.a.x, brick.a.y, brick.a.z - dist},
		b: Pos{brick.b.x, brick.b.y, brick.b.z - dist},
	}
	return new, dist > 0
}

func parse(input string) (bricks []Brick) {
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		brick := Brick{}
		for i, part := range strings.Split(line, "~") {
			for j, s := range strings.Split(part, ",") {
				coord, err := strconv.Atoi(s)
				if err != nil {
					log.Fatal(err)
				}
				switch i {
				case 0:
					switch j {
					case 0:
						brick.a.x = coord
					case 1:
						brick.a.y = coord
					case 2:
						brick.a.z = coord
					}
				case 1:
					switch j {
					case 0:
						brick.b.x = coord
					case 1:
						brick.b.y = coord
					case 2:
						brick.b.z = coord
					}
				}
			}
		}

		// Flip the bricks so that a is always the lower coordinate. This isn't
		// actually needed for the input, but this helps generalize.
		if brick.a.x > brick.b.x {
			brick.a.x, brick.b.x = brick.b.x, brick.a.x
		} else if brick.a.y > brick.b.y {
			brick.a.y, brick.b.y = brick.b.y, brick.a.y
		} else if brick.a.z > brick.b.z {
			brick.a.z, brick.b.z = brick.b.z, brick.a.z
		}

		bricks = append(bricks, brick)
	}
	return bricks
}
