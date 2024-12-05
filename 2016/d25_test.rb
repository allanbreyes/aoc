# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd25'

class TestD25 < Minitest::Test
  # rubocop:disable Metrics/MethodLength
  def setup
    @example = <<~EXAMPLE
      cpy a d
      cpy 11 c
      cpy 231 b
      inc d
      dec b
      jnz b -2
      dec c
      jnz c -5
      cpy d a
      jnz 0 0
      cpy a b
      cpy 0 a
      cpy 2 c
      jnz b 2
      jnz 1 6
      dec b
      dec c
      jnz c -4
      inc a
      jnz 1 -7
      cpy 2 b
      jnz c 2
      jnz 1 4
      dec b
      dec c
      jnz 1 -4
      jnz 0 0
      out b
      jnz a -19
      jnz 1 -21
    EXAMPLE
  end

  def test_clock?
    solver = D25.new(@example)

    assert solver.clock?([0, 1, 0, 1, 0, 1, 0, 1, 0, 1])
    refute solver.clock?([1, 0, 1, 0, 1, 0, 1, 0, 1, 0])
    refute solver.clock?([1, 1, 1, 0, 1, 1, 1, 0, 1, 1])
  end

  def test_part1
    skip 'slow test' unless ENV['SLOW'] == '25'
    solver = D25.new(@example)

    assert_equal 189, solver.part1
  end
end
