# frozen_string_literal: true

MOVES = {
  'U' => [-1, 0],
  'D' => [1, 0],
  'L' => [0, -1],
  'R' => [0, 1]
}.freeze
KEYPAD1 = [
  %w[. . . . .],
  %w[. 1 2 3 .],
  %w[. 4 5 6 .],
  %w[. 7 8 9 .],
  %w[. . . . .]
].freeze
KEYPAD2 = [
  %w[. . . . . . .],
  %w[. . . 1 . . .],
  %w[. . 2 3 4 . .],
  %w[. 5 6 7 8 9 .],
  %w[. . A B C . .],
  %w[. . . D . . .],
  %w[. . . . . . .]
].freeze

class D02
  def initialize(input)
    @input = input
    @pos = [0, 0]
  end

  def part1
    keypad = KEYPAD1
    @pos = [2, 2]
    parse.map do |row|
      row.each { |dir| move(dir, keypad) }
      keypad[@pos[0]][@pos[1]]
    end.join.to_i
  end

  def part2
    keypad = KEYPAD2
    @pos = [3, 1]
    parse.map do |row|
      row.each { |dir| move(dir, keypad) }
      keypad[@pos[0]][@pos[1]]
    end.join
  end

  def move(dir, keypad)
    new_pos = @pos.zip(MOVES[dir]).map(&:sum)
    @pos = new_pos if keypad[new_pos[0]][new_pos[1]] != '.'
  end

  def parse
    @input.strip
          .split("\n")
          .map(&:chars)
  end
end
