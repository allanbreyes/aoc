package d08

import (
	"regexp"
	"strings"
)

type Node struct {
	label string
	left  *Node
	right *Node

	// Part 2
	start bool
	end   bool
}

func SolvePart1(input string) int {
	dirs, nodes := parse(input)

	i := 0
	node := nodes["AAA"]
	for {
		dir := dirs[i%len(dirs)]
		if node.label == "ZZZ" {
			break
		} else if dir == "L" {
			node = node.left
		} else if dir == "R" {
			node = node.right
		}

		i++
	}
	return i
}

func SolvePart2(input string) int {
	dirs, nodes := parse(input)

	cursors := []*Node{}
	for _, node := range nodes {
		if node.start {
			cursors = append(cursors, node)
		}
	}
	steps := make([]int, len(cursors))

	for c, cursor := range cursors {
		i := 0

		node := cursor
		for {
			dir := dirs[i%len(dirs)]
			if node.end {
				break
			} else if dir == "L" {
				node = node.left
			} else if dir == "R" {
				node = node.right
			}

			i++
		}

		steps[c] = i
	}

	return LCM(steps[0], steps[1], steps[2:]...)
}

// Cribbed from https://siongui.github.io/2017/06/03/go-find-lcm-by-gcd/
func GCD(a, b int) int {
	for b != 0 {
		t := b
		b = a % b
		a = t
	}
	return a
}

func LCM(a, b int, integers ...int) int {
	result := a * b / GCD(a, b)

	for i := 0; i < len(integers); i++ {
		result = LCM(result, integers[i])
	}

	return result
}

func parse(input string) ([]string, map[string]*Node) {
	parts := strings.Split(strings.TrimSpace(input), "\n\n")
	header := strings.Split(parts[0], "")
	body := [][]string{}

	re := regexp.MustCompile(`([0-9A-Z]+) = \(([0-9A-Z]+), ([0-9A-Z]+)\)`)
	for _, line := range strings.Split(parts[1], "\n") {
		matches := re.FindStringSubmatch(line)
		body = append(body, matches[1:])
	}

	// First pass
	nodes := map[string]*Node{}
	dummy := Node{}
	for _, record := range body {
		label := record[0]
		start := label[2] == 'A'
		end := label[2] == 'Z'
		nodes[label] = &Node{label, &dummy, &dummy, start, end}
	}

	// Second pass
	for _, record := range body {
		label := record[0]
		nodes[label].left = nodes[record[1]]
		nodes[label].right = nodes[record[2]]
	}

	return header, nodes
}
