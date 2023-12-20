package d20

import (
	"fmt"
	"log"
	"strings"
)

type ModuleKind int
type Label string
type Signal int
type ModuleMap map[Label]*Module

const (
	Broadcast ModuleKind = iota
	FlipFlop
	Conjunction
	Dummy
)

const (
	Low Signal = iota
	High
)

type Module struct {
	kind  ModuleKind
	label Label
	in    []Label
	out   []Label
	state map[Label]Signal
}

func (m Module) String() string {
	prefix := ""
	if m.kind == FlipFlop {
		prefix = "%"
	} else if m.kind == Conjunction {
		prefix = "&"
	} else if m.kind == Dummy {
		prefix = "#"
	}
	return fmt.Sprintf("%s%s: %v, in: %v, out: %v", prefix, m.label, m.state, m.in, m.out)
}

type Pulse struct {
	src   Label
	value Signal
	dst   Label
}

func (p Pulse) String() string {
	return fmt.Sprintf("%s -%d-> %s", p.src, p.value, p.dst)
}

type Probe struct {
	src   Label
	value Signal
	dst   Label
}

func SolvePart1(input string) (ans int) {
	modules := parse(input)
	lows, highs := 0, 0

	for i := 0; i < 1000; i++ {
		low, high, _ := press(modules, Probe{})
		lows += low
		highs += high
	}

	return lows * highs
}

func SolvePart2(input string) (ans int) {
	modules := parse(input)
	// NOTE: this won't generalize if the rx node doesn't have a single
	// precursor conjunction module! Example from my input:
	// &zh: map[bp:0 pd:0 th:0 xc:0], in: [th pd bp xc], out: [rx]
	con := modules["rx"].in[0]
	factors := []int{}
	for _, in := range modules[con].in {
		probe := Probe{in, High, con}
		clone := parse(input) // TODO: use deep copy instead
		for i := 0; i < 5_000; i++ {
			_, _, activated := press(clone, probe)
			if activated {
				factors = append(factors, i+1)
				break
			}
		}
	}

	return LCM(factors...)
}

func press(modules ModuleMap, probe Probe) (low, high int, activated bool) {
	queue := []Pulse{{"button", Low, "broadcaster"}}
	for {
		if len(queue) == 0 {
			break
		}

		pulse := queue[0]
		queue = queue[1:]

		if pulse.value == Low {
			low++
		} else if pulse.value == High {
			high++
		}

		if pulse.src == probe.src && pulse.value == probe.value && pulse.dst == probe.dst {
			activated = true
			break
		}

		module := modules[pulse.dst]
		switch module.kind {
		case Broadcast:
			for _, out := range module.out {
				queue = append(queue, Pulse{module.label, pulse.value, out})
			}
		case FlipFlop:
			if pulse.value == Low {
				ff := (module.state["$ff"] + 1) % 2
				module.state["$ff"] = ff
				value := Signal(ff)

				for _, out := range module.out {
					queue = append(queue, Pulse{module.label, value, out})
				}
			}
		case Conjunction:
			module.state[pulse.src] = pulse.value
			value := Low
			for _, mem := range module.state {
				if mem == Low {
					value = High
					break
				}
			}

			for _, out := range module.out {
				queue = append(queue, Pulse{module.label, value, out})
			}
		}
	}

	return low, high, activated
}

// Modified from d08
func GCD(a, b int) int {
	for b != 0 {
		t := b
		b = a % b
		a = t
	}
	return a
}

func LCM(integers ...int) int {
	a := integers[0]
	b := integers[1]
	result := a * b / GCD(a, b)
	integers = integers[2:]

	for i := 0; i < len(integers); i++ {
		result = LCM(result, integers[i])
	}

	return result
}

func parse(input string) (modules ModuleMap) {
	modules = make(ModuleMap)

	// Take a first pass and instantiate the modules
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		parts := strings.Split(line, " -> ")
		if len(parts) != 2 || len(parts[0]) < 2 || len(parts[1]) == 0 {
			log.Fatalf("invalid line: %s", line)
		}

		var kind ModuleKind
		var label Label
		state := map[Label]Signal{}
		if parts[0][0] == '%' {
			kind = FlipFlop
			label = Label(parts[0][1:])
			state = map[Label]Signal{"$ff": 0}
		} else if parts[0][0] == '&' {
			kind = Conjunction
			label = Label(parts[0][1:])
		} else if parts[0] == "broadcaster" {
			kind = Broadcast
			label = "broadcaster"
		} else {
			log.Fatalf("invalid module: %s", parts[0])
		}

		out := []Label{}
		for _, label := range strings.Split(parts[1], ", ") {
			label = strings.TrimSpace(label)
			out = append(out, Label(label))
		}

		modules[label] = &Module{
			kind:  kind,
			label: label,
			in:    []Label{},
			out:   out,
			state: state,
		}
	}

	// Take a second pass to reify dummies, set inputs, and conjunction state
	for label, module := range modules {
		for _, out := range module.out {
			if _, ok := modules[out]; !ok {
				modules[out] = &Module{
					kind:  Dummy,
					label: out,
				}
			}
			modules[out].in = append(modules[out].in, label)
			if modules[out].kind == Conjunction {
				modules[out].state[label] = Low
			}
		}
	}

	return modules
}
