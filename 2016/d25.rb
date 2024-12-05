# frozen_string_literal: true

require_relative 'asm'

THRESHOLD = 10
MAX_GUESS = 10**6

class D25
  def initialize(input)
    @input = input
  end

  def part1
    a = 0
    loop do
      output = simulate(a)
      break if clock?(output)

      a += 1
    end
    a
  end

  def simulate(a = 0, threshold = THRESHOLD)
    asm = Assembunny.new(@input)
    asm.collapse!

    asm.registers[:a] = a
    output = []
    asm.run! do |out|
      output << out
      break if output.length >= threshold
    end
    output
  end

  def clock?(output, threshold = THRESHOLD)
    return false if output.length < threshold

    evens, odds = output.partition.with_index { |_, i| i.even? }
    evens.all?(&:zero?) && odds.all? { |e| e == 1 }
  end

  def part2
    '⭐'
  end

  def parse
    @input.strip.split("\n")
  end
end
