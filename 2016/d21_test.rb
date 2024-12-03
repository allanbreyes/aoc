# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd21'

class TestD21 < Minitest::Test
  def setup
    @example = <<~EXAMPLE
      swap position 4 with position 0
      swap letter d with letter b
      reverse positions 0 through 4
      rotate left 1 step
      move position 1 to position 4
      move position 3 to position 0
      rotate based on position of letter b
      rotate based on position of letter d
    EXAMPLE

    @seed = 'abcde'
    @scrambled = 'decab'
    @solver = D21.new(@example, @seed, @scrambled)
  end

  def test_operations
    assert_equal 'ebcda', @solver.send(:swap_position, @seed, 4, 0)
    assert_equal 'edcba', @solver.send(:swap_letter, 'ebcda', 'd', 'b')
    assert_equal 'bcdea', @solver.send(:rotate, 'abcde', -1)
    assert_equal 'eabcd', @solver.send(:rotate, 'abcde', 1)
    assert_equal 'ecabd', @solver.send(:rotate_on_letter, 'abdec', 'b')
    assert_equal 'abcde', @solver.send(:reverse_positions, 'edcba', 0, 4)
    assert_equal 'bdeac', @solver.send(:move, 'bcdea', 1, 4)
    assert_equal 'abdec', @solver.send(:move, 'bdeac', 3, 0)

    assert_equal 'afbgdhce', @solver.send(:undo_rotate_on_letter, 'fbgdhcea', 'h')
  end

  def test_part1
    assert_equal @scrambled, @solver.part1
  end

  def test_part2
    assert_equal @seed, @solver.part2
  end
end
