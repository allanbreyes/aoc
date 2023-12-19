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

func SolvePart1(input string) (ans int) {
	workflows, parts := parse(input)

	accepted := []Part{}

	for _, part := range parts {
		label := "in"
		for {
			if label == "A" {
				accepted = append(accepted, part)
				break
			} else if label == "R" {
				break
			}

			workflow := workflows[label]
			for i, rule := range workflow.rules {
				if i == len(workflow.rules)-1 {
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
				}

				if valid {
					label = rule.dst
					break
				}
			}
		}
	}

	for _, part := range accepted {
		ans += part.rate()
	}
	return ans
}

func SolvePart2(input string) (ans int) {
	return
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
