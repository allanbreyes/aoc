# frozen_string_literal: true

require 'pry'
require_relative 'asm'

class D23
  def initialize(input)
    @input = input
  end

  def part1
    asm = Assembunny.new(@input)
    asm.registers[:a] = 7
    asm.collapse!
    asm.run!
    asm.registers[:a]
  end

  def part2
    asm = Assembunny.new(@input)
    asm.registers[:a] = 12
    asm.collapse!
    asm.run!
    asm.registers[:a]
  end
end
