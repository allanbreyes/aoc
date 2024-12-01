# frozen_string_literal: true

class D03
  def initialize(input)
    @input = input
  end

  def part1
    parse.count { |sides| valid? sides }
  end

  def part2
    parse.each_slice(3).map(&:transpose).flatten(1)
         .count { |sides| valid? sides }
  end

  def valid?(sides)
    a, b, c = sides.sort
    a + b > c
  end

  def parse
    @input.strip
          .split("\n")
          .map { |line| line.strip.split.map(&:to_i) }
  end
end
