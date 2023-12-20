package d19

import (
	"log"
	"regexp"
	"strconv"
	"strings"
)

type Part struct {
	x, m, a, s int
}

func (p Part) get(cat string) int {
	switch cat {
	case "x":
		return p.x
	case "m":
		return p.m
	case "a":
		return p.a
	case "s":
		return p.s
	default:
		log.Fatalf("unknown category: %s", cat)
	}
	return -1
}

func (p Part) rate() int {
	return p.x + p.m + p.a + p.s
}

type Rule struct {
	cat  string
	op   string
	val  int
	dst  string
	coda bool
}

type Workflow struct {
	label string
	rules []Rule
}

type Range struct {
	min, max int
}

type Search struct {
	x, m, a, s Range
	label      string
	ruleIndex  int
}

func (s Search) diffs() (res []int) {
	res = append(res, s.x.max-s.x.min)
	res = append(res, s.m.max-s.m.min)
	res = append(res, s.a.max-s.a.min)
	res = append(res, s.s.max-s.s.min)
	return
}

func (s Search) get(cat string) Range {
	switch cat {
	case "x":
		return s.x
	case "m":
		return s.m
	case "a":
		return s.a
	case "s":
		return s.s
	}
	return Range{-1, -1}
}

func (s Search) set(cat string, min int, max int) Search {
	rg := Range{min, max}
	switch cat {
	case "x":
		s.x = rg
	case "m":
		s.m = rg
	case "a":
		s.a = rg
	case "s":
		s.s = rg
	}
	return s
}

func SolvePart1(input string) (ans int) {
	workflows, parts := parse(input)
	accepted := []Part{}

	for _, part := range parts {
		if run(part, workflows) {
			accepted = append(accepted, part)
		}
	}

	for _, part := range accepted {
		ans += part.rate()
	}

	return ans
}

func SolvePart2(input string) (ans int) {
	workflows, _ := parse(input)

	stack := []Search{
		{x: Range{1, 4000}, m: Range{1, 4000}, a: Range{1, 4000}, s: Range{1, 4000}, label: "in"},
	}
	for {
		if len(stack) == 0 {
			break
		}
		search := stack[len(stack)-1]
		stack = stack[:len(stack)-1]

		if search.label == "A" {
			acc := 1
			for _, diff := range search.diffs() {
				acc *= diff + 1
			}
			ans += acc
			continue
		} else if search.label == "R" {
			continue
		}

		rule := workflows[search.label].rules[search.ruleIndex]
		acc, rej := search, search
		acc.label = rule.dst
		acc.ruleIndex = 0
		rej.label = search.label
		rej.ruleIndex++

		if rule.op == ">" {
			acc = acc.set(rule.cat, rule.val+1, acc.get(rule.cat).max)
			rej = rej.set(rule.cat, rej.get(rule.cat).min, rule.val)
		} else if rule.op == "<" {
			acc = acc.set(rule.cat, acc.get(rule.cat).min, rule.val-1)
			rej = rej.set(rule.cat, rule.val, rej.get(rule.cat).max)
		}
		stack = append(stack, acc)
		if !rule.coda {
			stack = append(stack, rej)
		}
	}

	return ans
}

func run(part Part, workflows map[string]Workflow) (accepted bool) {
	label := "in"
	for {
		if label == "A" {
			return true
		} else if label == "R" {
			return false
		}

		workflow := workflows[label]
		for _, rule := range workflow.rules {
			if rule.coda {
				label = rule.dst
				break
			}

			left := part.get(rule.cat)
			var valid bool
			switch rule.op {
			case "<":
				valid = left < rule.val
			case ">":
				valid = left > rule.val
			default:
				log.Fatalf("unknown op: %s", rule.op)
			}

			if valid {
				label = rule.dst
				break
			}
		}
	}
}

func parse(input string) (workflows map[string]Workflow, parts []Part) {
	stanzas := strings.Split(strings.TrimSpace(input), "\n\n")
	workflowRegex := regexp.MustCompile(`^([a-z]+){(.+)}$`)
	ruleRegex := regexp.MustCompile(`^([a-z]+)([<>])(\d+):([a-zAR]+)$`)
	partRegex := regexp.MustCompile(`^{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}$`)

	workflows = make(map[string]Workflow)

	for _, line := range strings.Split(stanzas[0], "\n") {
		match := workflowRegex.FindStringSubmatch(line)
		if match == nil {
			log.Fatalf("failed to parse workflow: %s", line)
		}
		label := match[1]
		chunks := strings.Split(match[2], ",")
		rules := make([]Rule, len(chunks))
		for i, chunk := range chunks {
			if i == len(chunks)-1 {
				rules[i].dst = chunk
				rules[i].coda = true
				break
			}

			match = ruleRegex.FindStringSubmatch(chunk)
			if match == nil {
				log.Fatalf("failed to parse rule: %s", chunk)
			}

			rules[i].cat = match[1]
			rules[i].op = match[2]
			val, _ := strconv.Atoi(match[3])
			rules[i].val = val
			rules[i].dst = match[4]
		}

		workflows[label] = Workflow{label, rules}
	}

	for _, line := range strings.Split(stanzas[1], "\n") {
		match := partRegex.FindStringSubmatch(line)
		if match == nil {
			log.Fatalf("failed to parse part: %s", line)
		}
		x, _ := strconv.Atoi(match[1])
		m, _ := strconv.Atoi(match[2])
		a, _ := strconv.Atoi(match[3])
		s, _ := strconv.Atoi(match[4])
		parts = append(parts, Part{x, m, a, s})
	}

	return workflows, parts
}
