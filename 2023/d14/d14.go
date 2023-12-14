package d14

import (
	"fmt"
	"log"
	"strings"

	"gonum.org/v1/gonum/mat"
)

const (
	Empty = iota
	Cube
	Round
)

type Direction int

const (
	N Direction = iota
	E
	S
	W
)

func SolvePart1(input string) (ans int) {
	grid := parse(input)
	grid = roll(grid, N)
	return load(grid)
}

func SolvePart2(input string) (ans int) {
	grid := parse(input)
	seq := []int{}

	// Warm up and sample the spin cycles
	warmup, sample := 200, 300
	for i := 0; i < sample; i++ {
		grid = spin(grid)
		if i >= warmup {
			seq = append(seq, load(grid))
		}
	}

	// Find the period
	period, ok := findPeriod(seq)
	if !ok {
		log.Fatalf("could not find period, try a larger warm up or sample size")
	}

	// Extrapolate
	cycle := seq[:period]
	return cycle[(1000000000-warmup-1)%period]
}

func roll(grid *mat.Dense, dir Direction) (new *mat.Dense) {
	m, n := shape(grid)
	new = mat.NewDense(m, n, nil)
	switch dir {
	case N:
		for j := 0; j < n; j++ {
			col := make([]float64, m)
			mat.Col(col, j, grid)
			new.SetCol(j, rollSlice(col))
		}
	case S:
		for j := 0; j < n; j++ {
			col := make([]float64, m)
			mat.Col(col, j, grid)
			new.SetCol(j, reverse(rollSlice(reverse(col))))
		}
	case W:
		for i := 0; i < m; i++ {
			row := make([]float64, n)
			mat.Row(row, i, grid)
			new.SetRow(i, rollSlice(row))
		}
	case E:
		for i := 0; i < m; i++ {
			row := make([]float64, n)
			mat.Row(row, i, grid)
			new.SetRow(i, reverse(rollSlice(reverse(row))))
		}
	}
	return new
}

func rollSlice(slice []float64) (new []float64) {
	new = make([]float64, len(slice))
	for i := 0; i < len(slice); i++ {
		if slice[i] == Cube {
			new[i] = Cube
		}
	}

	for i := 0; i < len(slice); i++ {
		if slice[i] == Round {
			for j := i; j >= 0; j-- {
				if j-1 < 0 || new[j-1] != Empty {
					new[j] = Round
					break
				}
			}
		}
	}

	return new
}

func spin(grid *mat.Dense) (new *mat.Dense) {
	for _, dir := range []Direction{N, W, S, E} {
		grid = roll(grid, dir)
	}
	return grid
}

func load(grid *mat.Dense) (sum int) {
	m, n := shape(grid)
	for i := 0; i < m; i++ {
		for j := 0; j < n; j++ {
			if grid.At(i, j) == Round {
				sum += m - i
			}
		}
	}

	return sum
}

func findPeriod(seq []int) (period int, ok bool) {
period:
	for p := 2; p < len(seq)/2; p++ {
		// Chunk the sequence into p-sized chunks
		chunks := [][]int{}
		for i := 0; i < len(seq)-p; i += p {
			chunks = append(chunks, seq[i:i+p])
		}

		// Check if all chunks are equal
		for j := 0; j < p; j++ {
			val := chunks[0][j]
			for k := 1; k < len(chunks); k++ {
				if chunks[k][j] != val {
					continue period
				}
			}
		}

		return p, true
	}
	return -1, false
}

func reverse(slice []float64) (new []float64) {
	new = make([]float64, len(slice))
	for i := 0; i < len(slice); i++ {
		new[i] = slice[len(slice)-i-1]
	}
	return new
}

func draw(grid *mat.Dense) {
	m, n := shape(grid)
	for i := 0; i < m; i++ {
		row := make([]float64, n)
		mat.Row(row, i, grid)
		for _, v := range row {
			switch v {
			case Empty:
				fmt.Print(".")
			case Cube:
				fmt.Print("#")
			case Round:
				fmt.Print("O")
			}
		}
		fmt.Println()
	}
	fmt.Println()
}

func shape(grid *mat.Dense) (m, n int) {
	return grid.RawMatrix().Rows, grid.RawMatrix().Cols
}

func parse(input string) *mat.Dense {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	m, n := len(lines), len(lines[0])
	grid := mat.NewDense(m, n, nil)

	for i, line := range lines {
		for j, char := range line {
			switch char {
			case '.':
				grid.Set(i, j, Empty)
			case '#':
				grid.Set(i, j, Cube)
			case 'O':
				grid.Set(i, j, Round)
			default:
				log.Fatalf("unknown char %q", char)
			}
		}
	}

	return grid
}
