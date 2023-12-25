package d25

import (
	"log"
	"regexp"
	"sort"
	"strings"

	"gonum.org/v1/gonum/graph"
	"gonum.org/v1/gonum/graph/network"
	"gonum.org/v1/gonum/graph/simple"
	"gonum.org/v1/gonum/graph/topo"
	"gonum.org/v1/gonum/stat/combin"
)

func SolvePart1(input string) (ans int) {
	g, _ := parse(input)

	counts := map[int64]int{}
	for _, node := range graph.NodesOf(g.Nodes()) {
		counts[node.ID()] = 0
	}

	top := rank(network.Betweenness(g))[:6]
	if len(top) < 6 {
		log.Fatalf("not enough nodes: %v", top)
	}
	cps := []int64{}
	for _, pair := range top {
		cps = append(cps, pair.Key)
	}

	pairs := [][]int64{}
	for i, a := range cps {
		for _, b := range cps[i+1:] {
			pairs = append(pairs, []int64{a, b})
		}
	}

	for _, combo := range combin.Combinations(len(pairs), 3) {
		h := simple.NewUndirectedGraph()
		graph.Copy(h, g)

		for _, i := range combo {
			pair := pairs[i]
			a, b := pair[0], pair[1]
			h.RemoveEdge(a, b)
		}

		components := topo.ConnectedComponents(h)
		if len(components) == 2 {
			A, B := components[0], components[1]
			return len(A) * len(B)
		}
	}

	log.Fatalf("could not find a solution")
	return -1
}

func SolvePart2(input string) (ans int) {
	return 2023
}

func rank(betweenness map[int64]float64) PairList {
	pl := make(PairList, len(betweenness))
	i := 0
	for k, v := range betweenness {
		pl[i] = Pair{k, v}
		i++
	}
	sort.Sort(sort.Reverse(pl))
	return pl
}

type Pair struct {
	Key   int64
	Value float64
}

type PairList []Pair

func (p PairList) Len() int           { return len(p) }
func (p PairList) Less(i, j int) bool { return p[i].Value < p[j].Value }
func (p PairList) Swap(i, j int)      { p[i], p[j] = p[j], p[i] }

func parse(input string) (g *simple.UndirectedGraph, lookup map[string]graph.Node) {
	lookup = make(map[string]graph.Node)
	g = simple.NewUndirectedGraph()

	delimiter := regexp.MustCompile("(: | )")
	for _, line := range strings.Split(strings.TrimSpace(input), "\n") {
		tokens := delimiter.Split(line, -1)
		for _, token := range tokens {
			if _, ok := lookup[token]; !ok {
				node := g.NewNode()
				g.AddNode(node)
				lookup[token] = node
			}
		}

		node := lookup[tokens[0]]
		for _, token := range tokens[1:] {
			g.SetEdge(g.NewEdge(node, lookup[token]))
		}
	}

	return g, lookup
}
