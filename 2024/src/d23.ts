import { readFileSync } from "fs";

type Cluster = Set<string>;

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    const triads: Set<string> = new Set();

    this.bronKerbosch(this.parse()).forEach((clique) => {
      const nodes = [...clique];
      const tnodes = nodes.filter((node) => node.startsWith("t"));
      if (clique.size >= 3 && tnodes.length > 0) {
        // Generate triads from each clique
        tnodes.forEach((t) => {
          nodes.forEach((u) => {
            nodes.forEach((v) => {
              const triad = new Set([t, u, v]);
              if (triad.size === 3) triads.add(this.canonicalize(...triad));
            });
          });
        });
      }
    });

    return triads.size;
  }

  part2() {
    let max: Cluster = new Set();

    this.bronKerbosch(this.parse()).forEach((clique) => {
      if (clique.size > max.size) max = clique;
    });

    return this.canonicalize(...max);
  }

  private canonicalize(...nodes: string[]) {
    return nodes.sort().join(",");
  }

  // See: https://www.geeksforgeeks.org/maximal-clique-problem-recursive-solution/
  private bronKerbosch(
    graph: Map<string, Cluster>,
    P: Cluster | null = null,
    R: Cluster = new Set(),
    X: Cluster = new Set(),
  ) {
    P = P || new Set(graph.keys());

    let cliques = new Set<Cluster>();
    if (P.size === 0 && X.size === 0) {
      cliques.add(new Set(R));
    }
    for (let v of P) {
      let newR = new Set(R);
      newR.add(v);
      let newP = new Set([...P].filter((x) => graph.get(v)!.has(x)));
      let newX = new Set([...X].filter((x) => graph.get(v)!.has(x)));
      cliques = new Set([
        ...cliques,
        ...this.bronKerbosch(graph, newP, newR, newX),
      ]);
      P.delete(v);
      X.add(v);
    }
    return cliques;
  }

  private parse() {
    const neighbors: Map<string, Cluster> = new Map();
    const edges = this.input
      .trim()
      .split("\n")
      .map((line) => {
        return line.split("-");
      });

    for (const edge of edges) {
      const [a, b] = edge;
      (neighbors.get(a) || neighbors.set(a, new Set()).get(a)!).add(b);
      (neighbors.get(b) || neighbors.set(b, new Set()).get(b)!).add(a);
    }

    return neighbors;
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/23.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
