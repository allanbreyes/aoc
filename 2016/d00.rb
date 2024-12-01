# frozen_string_literal: true

class D00
  def initialize(input)
    @input = input
  end

  def part1
    parse.length
  end

  def part2
    parse.length
  end

  def parse
    @input.strip.split("\n")
  end
end
