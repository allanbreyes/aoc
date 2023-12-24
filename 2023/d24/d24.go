package d24

import (
	"log"
	"reflect"
	"regexp"
	"strconv"
	"strings"
)

type Vec struct {
	x, y, z    float64
	vx, vy, vz float64
}

func (v Vec) get(name string) float64 {
	r := reflect.ValueOf(v)
	f := reflect.Indirect(r).FieldByName(name)
	return f.Float()
}

type Point struct {
	x, y, z float64
}

type Set map[float64]struct{}

func (s Set) Add(v float64) {
	s[v] = struct{}{}
}

func (s Set) Contains(v float64) bool {
	_, ok := s[v]
	return ok
}

func (s Set) Intersection(t Set) (u Set) {
	u = make(Set)
	for v := range s {
		if t.Contains(v) {
			u.Add(v)
		}
	}
	return u
}

func (s Set) Peek() float64 {
	for k := range s {
		return k
	}
	return -1.
}

func SolvePart1(input string) (ans int) {
	return subSolvePart1(input, 200000000000000, 400000000000000)
}

func subSolvePart1(input string, min float64, max float64) (ans int) {
	vecs := parse(input)
	for i, a := range vecs {
		for j := i + 1; j < len(vecs); j++ {
			b := vecs[j]
			p, intersects := intersect2d(a, b)
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
	return subSolvePart2(input, 100, 1000)
}

func subSolvePart2(input string, vmin, vrange int) (ans int) {
	vecs := parse(input)

	// Find possible velocities
	// Shout-out to /u/TheZigerionScammer for the strategy and implementation.
	// I likely wouldn't have been able to solve this with a CSP solver! Note
	// that this also won't generalize if there isn't a specific constraint
	// produced on the velocities due to overlapping vector components.
	X := make(Set)
	Y := make(Set)
	Z := make(Set)

	for i, a := range vecs {
		for j := i + 1; j < len(vecs); j++ {
			b := vecs[j]

			X = findSet(a, b, X, "x", vmin, vrange)
			Y = findSet(a, b, Y, "y", vmin, vrange)
			Z = findSet(a, b, Z, "z", vmin, vrange)
		}
	}

	if len(X) < 1 || len(Y) < 1 || len(Z) < 1 {
		log.Fatal("no valid set")
	}

	// Solve for starting position given resolved velocities
	r := Vec{0, 0, 0, X.Peek(), Y.Peek(), Z.Peek()}
	a, b := vecs[0], vecs[1]
	ma := (a.vy - r.vy) / (a.vx - r.vx)
	mb := (b.vy - r.vy) / (b.vx - r.vx)
	ca := a.y - ma*a.x
	cb := b.y - mb*b.x
	r.x = (cb - ca) / (ma - mb)
	r.y = ma*r.x + ca
	t := (r.x - a.x) / (a.vx - r.vx)
	r.z = a.z + (a.vz-r.vz)*t
	return int(r.x + r.y + r.z)
}

func abs(x float64) float64 {
	if x < 0 {
		return -x
	}
	return x
}

func intersect2d(a, b Vec) (point Point, intersects bool) {
	t := ((b.y-a.y)*b.vx - (b.x-a.x)*b.vy) / (b.vx*a.vy - b.vy*a.vx)
	u := ((b.y-a.y)*a.vx - (b.x-a.x)*a.vy) / (b.vx*a.vy - b.vy*a.vx)
	x, y := a.x+a.vx*t, a.y+a.vy*t
	return Point{x, y, 0}, t >= 0 && u >= 0
}

func findSet(a, b Vec, current Set, dim string, vmin, vrange int) Set {
	vdim := "v" + dim

	ax := a.get(dim)
	bx := b.get(dim)
	avx := a.get(vdim)
	bvx := b.get(vdim)

	if int(avx) == int(bvx) && abs(avx) > float64(vmin) {
		new := make(Set)
		dx := int(bx - ax)
		for v := -vrange; v <= vrange; v++ {
			if float64(v) == avx {
				continue
			} else if dx%(v-int(avx)) == 0 {
				new.Add(float64(v))
			}
		}
		if len(current) == 0 {
			return new
		} else {
			return current.Intersection(new)
		}
	} else {
		return current
	}
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
