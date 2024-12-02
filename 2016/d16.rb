# frozen_string_literal: true

class D16
  attr_writer :size

  def initialize(input)
    @input = input
    @size = 272
  end

  def part1
    solve
  end

  def part2
    @size = 35_651_584
    solve
  end

  def solve
    data = parse
    data = expand(data) while data.length < @size
    checksum(data[0...@size])
  end

  def checksum(data)
    result = []
    data.chars.each_slice(2) do |a, b|
      result << (a == b ? '1' : '0')
    end
    if result.length.even?
      checksum(result.join)
    else
      result.join
    end
  end

  def expand(a)
    "#{a}0#{a.reverse.tr('01', '10')}"
  end

  def parse
    @input.strip
  end
end
