# frozen_string_literal: true

class Disc
  def initialize(positions, initial)
    @positions = positions
    @initial = initial
  end

  def pass?(t)
    ((@initial + t) % @positions).zero?
  end
end

class D15
  def initialize(input)
    @discs = parse(input)
  end

  def part1
    solve
  end

  def part2
    @discs << Disc.new(11, 0)
    solve
  end

  def solve
    t = 0
    loop do
      return t if simulate(t)

      t += 1
    end
  end

  def simulate(t)
    t += 1
    @discs.each_with_index do |disc, i|
      return false unless disc.pass?(t + i)
    end
    true
  end

  def parse(input)
    params = input.strip.split("\n").map do |line|
      line.match(/Disc #\d+ has (\d+) positions; at time=0, it is at position (\d+)/)
          .captures
          .map(&:to_i)
    end
    params.map { |positions, initial| Disc.new(positions, initial) }
  end
end
