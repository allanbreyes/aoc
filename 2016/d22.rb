# frozen_string_literal: true

require 'pathfinding'

# rubocop:disable Lint/StructNewOverride
FileNode = Struct.new(:x, :y, :size, :used, :avail, :use) do
  def xy
    [x, y]
  end

  def to_s
    "node-x#{x}-y#{y}"
  end

  def empty?
    used.zero?
  end

  def large?
    size > 100
  end
end

class D22
  def initialize(input)
    @input = input
  end

  def part1
    nodes = parse.sort_by(&:used)
    nodes.reduce(0) do |acc, node|
      next acc if node.used.zero?

      nodes.sort_by(&:avail).reverse.each do |other|
        next if node == other
        break if node.used > other.avail

        acc += 1
      end
      acc
    end
  end

  # rubocop:disable Metrics/AbcSize
  def part2
    # NOTE: this isn't generalizable. I plotted the values in a spreadsheet and
    # it was clear that there was one empty node, a horizontal wall of large
    # nodes, and mostly fungible nodes. My strategy here is to pathfind moving
    # the empty space to the left of the target, then do a 5-step loop to move
    # the target data 1 step to the left towards the access point.
    nodes = lookup_table(parse)
    xmax, ymax = nodes.keys.max

    access = [0, 0]
    target = [xmax, 0]
    empty = nodes.values.find { |node| node.used.zero? }.xy

    grid = Grid.new((0..ymax).map do |y|
      (0..xmax).map do |x|
        nodes[[x, y]].large? ? 1 : 0
      end
    end)

    finder = AStarFinder.new

    # Move the empty space to the left of the target
    steps = finder.find_path(grid.node(*empty), grid.node(target[0] - 1, target[1]), grid).length - 1

    # Loop to move the target data to the right of the access point
    steps += (finder.find_path(grid.node(*target), grid.node(access[0] + 1, access[1]), grid).length - 1) * 5

    # Move target data to the goal
    steps + 1
  end

  def lookup_table(_nodes)
    @lookup_table ||= parse.each_with_object({}) do |node, acc|
      acc[node.xy] = node
    end
  end

  def parse
    @input.strip.split("\n").map do |line|
      matches = line.scan(/\d+/).map(&:to_i)
      next if matches.length != 6

      x, y, size, used, avail, use = matches.map(&:to_i)
      FileNode.new(x, y, size, used, avail, use)
    end.compact
  end
end
