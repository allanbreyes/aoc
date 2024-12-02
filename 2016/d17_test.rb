# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'd17'

class TestD17 < Minitest::Test
  def setup
    @example0 = 'hijkl'
    @example1 = 'ihgpwlah'
    @example2 = 'kglvqrro'
    @example3 = 'ulqzkmiv'
  end

  def test_neighbors
    solver = D17.new(@example0)

    assert_equal [[0, 1, :D]], solver.neighbors([0, 0], '')
    assert_equal [[0, 0, :U], [1, 1, :R]], solver.neighbors([0, 1], 'D')
    assert_empty solver.neighbors([0, 1], 'DR')
    assert_equal [[1, 0, :R]], solver.neighbors([0, 0], 'DU')
    assert_empty solver.neighbors([1, 0], 'DUR')
  end

  def test_openings
    solver = D17.new(@example0)

    assert_equal %i[U D L], solver.openings
    assert_equal %i[U L R], solver.openings('D')
    assert_empty solver.openings('DR')
    assert_equal %i[R], solver.openings('DU')
    assert_empty solver.openings('DUR')
  end

  def test_part1
    assert_equal 'DDRRRD', D17.new(@example1).part1
    assert_equal 'DDUDRLRRUDRD', D17.new(@example2).part1
    assert_equal 'DRURDRUDDLLDLUURRDULRLDUUDDDRR', D17.new(@example3).part1
  end

  def test_part2
    skip 'slow test' unless ENV['SLOW'] == '17'

    assert_equal 370, D17.new(@example1).part2
    assert_equal 492, D17.new(@example2).part2
    assert_equal 830, D17.new(@example3).part2
  end
end
