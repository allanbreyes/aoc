import { Solver } from "./d25";

const example = `
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####`;

describe("d25 Solver", () => {
  const solver = new Solver(example);

  it("should solve part 1 examples", () => {
    expect(solver.part1()).toBe(3);
  });
});
