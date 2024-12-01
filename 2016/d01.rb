# frozen_string_literal: true

require 'set'

class D01
  @directions = [
    [0, -1], # North
    [1, 0],  # East
    [0, 1],  # South
    [-1, 0]  # West
  ]

  def initialize(input)
    @input = input
    @directions = self.class.instance_variable_get(:@directions)
    reset
  end

  def part1
    reset
    parse.each do |turn, dist|
      move turn, dist
    end
    @pos[0].abs + @pos[1].abs
  end

  def part2
    reset
    visited = Set[@pos.dup]
    parse.each do |turn, dist|
      move(turn, dist).each do |pos|
        return pos[0].abs + pos[1].abs if visited.include? pos

        visited << pos
      end
    end
  end

  def reset
    @pos = [0, 0]
    @dir = @directions[0]
  end

  def move(turn, dist)
    offset = turn == 'R' ? 1 : -1
    @dir = @directions[(@directions.index(@dir) + offset) % 4]
    visits = []
    dist.times do |_i|
      @pos = [@pos[0] + @dir[0], @pos[1] + @dir[1]]
      visits << @pos.dup
    end
    visits
  end

  def parse
    @input
      .split(', ')
      .map { |x| [x[0], x[1..].to_i] }
  end
end
