package d09

import (
	"log"
	"strconv"
	"strings"
)

func SolvePart1(input string) (sum int) {
	for _, seq := range parse(input) {
		new := extend(seq, false)
		sum += new[len(new)-1]
	}
	return
}

func SolvePart2(input string) (sum int) {
	for _, seq := range parse(input) {
		new := extend(seq, true)
		sum += new[0]
	}
	return
}

func derive(seq []int) (drv []int) {
	if len(seq) < 2 {
		log.Fatal("cannot derive sequence of length < 2")
	}

	for i := 1; i < len(seq); i++ {
		drv = append(drv, seq[i]-seq[i-1])
	}
	return drv
}

func extend(seq []int, prepend bool) (new []int) {
	drvs := [][]int{seq}

	ord := 0
	cur := seq

	// Build derivatives
	for {
		ord++
		cur = derive(cur)
		drvs = append(drvs, cur)

		if isZeroes(cur) {
			break
		}
	}

	// Extend the n-th derivative
	drvs[ord] = append(cur, 0)

	// Extend each, back to the original sequence
	for j := ord; j > 0; j-- {
		i := j - 1
		if prepend {
			// Part 2
			dx := drvs[j][0]
			drvs[i] = append([]int{drvs[i][0] - dx}, drvs[i]...)
		} else {
			// Part 1
			dx := drvs[j][len(drvs[j])-1]
			drvs[i] = append(drvs[i], drvs[i][len(drvs[i])-1]+dx)
		}
	}

	return drvs[0]
}

func isZeroes(seq []int) bool {
	for _, num := range seq {
		if num != 0 {
			return false
		}
	}
	return true
}

func parse(input string) [][]int {
	seqs := [][]int{}
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		seq := []int{}
		for _, tok := range strings.Split(line, " ") {
			num, _ := strconv.Atoi(tok)
			seq = append(seq, num)
		}
		seqs = append(seqs, seq)
	}
	return seqs
}
