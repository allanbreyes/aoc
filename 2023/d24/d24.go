package d24

import (
	"log"
	"regexp"
	"strconv"
	"strings"
)

type Vec struct {
	x, y, z    float64
	vx, vy, vz float64
}

type Point struct {
	x, y, z float64
}

func SolvePart1(input string) (ans int) {
	return subSolvePart1(input, 200000000000000, 400000000000000)
}

func subSolvePart1(input string, min float64, max float64) (ans int) {
	vecs := parse(input)
	for i, v1 := range vecs {
		for j := i + 1; j < len(vecs); j++ {
			v2 := vecs[j]
			p, intersects := intersect2d(v1, v2)
			if intersects {
				if p.x >= min && p.x <= max && p.y >= min && p.y <= max {
					ans++
				}
			}
		}
	}
	return ans
}

func SolvePart2(input string) (ans int) {
	return
}

func intersect2d(a, b Vec) (point Point, intersects bool) {
	t := ((b.y-a.y)*b.vx - (b.x-a.x)*b.vy) / (b.vx*a.vy - b.vy*a.vx)
	u := ((b.y-a.y)*a.vx - (b.x-a.x)*a.vy) / (b.vx*a.vy - b.vy*a.vx)
	x, y := a.x+a.vx*t, a.y+a.vy*t
	return Point{x, y, 0}, t >= 0 && u >= 0
}

func parse(input string) (vecs []Vec) {
	re := regexp.MustCompile("(, | @ )")
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		tokens := re.Split(line, -1)
		v := make([]float64, len(tokens))
		for i, token := range tokens {
			value, err := strconv.ParseFloat(strings.TrimSpace(token), 64)
			if err != nil {
				log.Fatal(err)
			}
			v[i] = value
		}
		vecs = append(vecs, Vec{v[0], v[1], v[2], v[3], v[4], v[5]})
	}
	return vecs
}
