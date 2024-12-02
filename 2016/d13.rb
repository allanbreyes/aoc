# frozen_string_literal: true

require 'pathfinding'

class D13
  def initialize(input, target = [31, 39])
    @input = input
    @fave = parse
    @pos = [1, 1]
    @target = target
  end

  def part1
    grid = Grid.new(matrix(100, 100))
    start = grid.node(*@pos)
    goal = grid.node(*@target)
    finder = AStarFinder.new
    finder.find_path(start, goal, grid).length - 1
  end

  def part2
    max_x = 50
    max_y = 50
    grid = Grid.new(matrix(max_x, max_y))
    start = grid.node(*@pos)

    # NOTE: this is wildly inefficient, but the problem space is small enough to
    # be brute-forced.
    reachable = 0
    (0..max_y).each do |y|
      (0..max_x).each do |x|
        next unless open?(x, y)

        finder = AStarFinder.new
        path = finder.find_path(start, grid.node(x, y), grid)
        next if path.nil?

        reachable += 1 if path.length - 1 <= 50
      end
    end
    reachable
  end

  def matrix(max_x, max_y)
    (0..max_y).map do |y|
      (0..max_x).map do |x|
        open?(x, y) ? 0 : 1
      end
    end
  end

  def open?(x, y)
    n = (x * x) + (3 * x) + (2 * x * y) + y + (y * y) + @fave
    n.to_s(2).count('1').even?
  end

  def parse
    @input.strip.to_i
  end
end
