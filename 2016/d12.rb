# frozen_string_literal: true

class D12
  attr_writer :a, :b, :c, :d

  def initialize(input)
    @input = input
  end

  def part1
    reset!
    run!
    @registers[:a]
  end

  def part2
    reset!
    @registers[:c] = 1
    run!
    @registers[:a]
  end

  def reset!
    @registers = { a: 0, b: 0, c: 0, d: 0 }
    @pc = 0
  end

  # rubocop:disable Metrics/*
  def run!
    program = parse
    while @pc < program.size
      jumped = false
      op, *args = program[@pc]
      case op
      when :cpy
        x, reg = args
        @registers[reg] = x.is_a?(Integer) ? x : @registers[x]
      when :inc
        reg, = args
        @registers[reg] += 1
      when :dec
        reg, = args
        @registers[reg] -= 1
      when :jnz
        x, offset = args
        if (x.is_a?(Integer) ? x : @registers[x]) != 0
          @pc += offset
          jumped = true
        end
      end
      @pc += 1 unless jumped
    end
  end

  def parse
    @input.strip.split("\n").map do |line|
      line.split.map { |x| x.match(/^[-\d]+/) ? x.to_i : x.to_sym }
    end.freeze
  end
end
