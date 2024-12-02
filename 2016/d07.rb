# frozen_string_literal: true

class D07
  def initialize(input)
    @input = input
  end

  def part1
    parse.select do |parts|
      supernets, hypernets = parts.partition.with_index { |_, i| i.even? }
      hypernets.none? { |str| abba?(str) } && supernets.any? { |str| abba?(str) }
    end.length
  end

  def part2
    parse.select do |nets|
      supernets, hypernets = nets.partition.with_index { |_, i| i.even? }
      supernets.flat_map { |str| abas(str) }.any? do |a, b, _a|
        hypernets.any? { |str| str.include?("#{b}#{a}#{b}") }
      end
    end.length
  end

  def abba?(str)
    str.chars.each_cons(4).any? do |a, b, c, d|
      a != b && a == d && b == c
    end
  end

  def abas(str)
    str.chars.each_cons(3).select do |a, b, c|
      a != b && a == c
    end
  end

  def parse
    @input.strip.split("\n").map do |line|
      line.split(/\[|\]/)
    end
  end
end
