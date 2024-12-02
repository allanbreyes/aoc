# frozen_string_literal: true

class D06
  def initialize(input)
    @input = input
  end

  def part1
    parse.map do |col|
      col.group_by(&:itself).max_by { |_, v| v.length }.first
    end.join
  end

  def part2
    parse.map do |col|
      col.group_by(&:itself).min_by { |_, v| v.length }.first
    end.join
  end

  def parse
    @input.strip.split("\n").map(&:chars).transpose
  end
end
