# frozen_string_literal: true

require 'pathfinding'

class D24
  def initialize(input)
    @input = input
    @walk = {}
  end

  def part1
    matrix, waypoints = parse
    plan(matrix, waypoints)
  end

  def part2
    matrix, waypoints = parse
    plan(matrix, waypoints, home: true)
  end

  # rubocop:disable Metrics/AbcSize
  def plan(matrix, waypoints, home: false)
    grid = Grid.new(matrix)
    finder = AStarFinder.new

    best = matrix.flatten.count(0) * 2 # Upper limit: touch every cell twice
    start, *rest = waypoints
    rest.permutation.each do |order|
      skip = false
      dist = walk(start, order.first, grid: grid, finder: finder).length - 1
      order.each_cons(2) do |a, b|
        dist += walk(a, b, grid: grid, finder: finder).length - 1
        if dist >= best
          skip = true
          break
        end
      end

      dist += walk(order.last, start, grid: grid, finder: finder).length - 1 if home
      best = [best, dist].min unless skip
    end.min
    best
  end

  def walk(a, b, grid:, finder:)
    @walk[[a, b]] ||= finder.find_path(grid.node(*a), grid.node(*b), grid)
  end

  def parse
    waypoints = {}
    matrix = @input.strip.split("\n").map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        case char
        when '0'..'9'
          waypoints[char.to_i] = [x, y]
          0
        when '.' then 0
        when '#' then 1
        else raise "Unknown character: #{char}"
        end
      end
    end
    [matrix, waypoints.sort.map(&:last)]
  end
end
