import { readFileSync } from "fs";

export class Solver {
  constructor(private readonly input: string) {}

  part1() {
    return this.parse().reduce((acc, seed) => {
      return acc + Number(this.prngAt(seed, 2000));
    }, 0);
  }

  part2() {
    const seeds = this.parse();
    const data = seeds.map((seed) => this.getSells(seed, 2000));

    // Get pool of keys
    let keys = new Set<string>();
    data.forEach((sells) => {
      keys = this.union(keys, new Set(sells.keys()));
    });

    // Brute-force the best price. There are some optimizations that we could do
    // here like a fast-out if we know that there's no way it'll beat the best
    // price so far, but this completes in a reasonable amount of time.
    let best = -Infinity;
    for (const key of keys) {
      const local = data.reduce((acc, sells) => {
        return acc + (sells.get(key) ?? 0);
      }, 0);
      best = Math.max(best, local);
    }

    return best;
  }

  prngAt(seed: bigint, n: number = 2000) {
    const prng = this.prng(seed);
    let secret = BigInt(seed);
    for (let i = 0; i < n; i++) {
      secret = prng.next().value!;
    }
    return secret;
  }

  getSells(seed: bigint, n: number = 2000) {
    const prng = this.prng(seed);
    const prices = [Number(seed % BigInt(10))];
    for (let i = 0; i < n; i++) {
      prices.push(Number(prng.next().value!) % 10);
    }

    const changes: number[] = [];
    for (let i = 0; i < prices.length - 1; i++) {
      changes.push(prices[i + 1] - prices[i]);
    }

    const sells = new Map<string, number>();
    changes.slice(3).forEach((_, i) => {
      const key = changes.slice(i, i + 4).join(",");
      const price = prices[i + 4];

      if (!sells.has(key)) sells.set(key, price);
    });

    return sells;
  }

  private *prng(seed: bigint) {
    let secret = seed;
    const mixprune = (a: bigint, b: bigint) => (a ^ b) % BigInt(16777216);

    while (true) {
      secret = mixprune(secret, secret * BigInt(64));
      secret = mixprune(secret, secret / BigInt(32));
      secret = mixprune(secret, secret * BigInt(2048));

      yield secret;
    }
  }

  private union(a: Set<string>, b: Set<string>) {
    // The frozen version of TypeScript/Node.js doesn't have Set.union
    const union = new Set<string>();
    for (const x of a) union.add(x);
    for (const x of b) union.add(x);
    return union;
  }

  private parse() {
    return this.input.trim().split("\n").map(BigInt);
  }
}

if (require.main === module) {
  const input = readFileSync("./inputs/22.txt", "utf8");
  const solver = new Solver(input);
  console.log(solver.part1());
  console.log(solver.part2());
}
