# frozen_string_literal: true

class D18
  def initialize(input, num_rows = nil)
    @input = input.strip
    @num_rows = num_rows
  end

  def part1
    solve(@num_rows || 40)
  end

  def part2
    solve(@num_rows || 400_000)
  end

  def solve(num_rows)
    row = @input.chars
    room = [row]
    (num_rows - 1).times do
      row = next_row(row)
      room << row
    end
    room.flatten.count('.')
  end

  def next_row(row)
    row.map.with_index do |center, i|
      left = i.zero? ? '.' : row[i - 1]
      right = i >= row.length - 1 ? '.' : row[i + 1]
      above = [left, center, right].join
      ['^^.', '.^^', '^..', '..^'].include?(above) ? '^' : '.'
    end
  end
end
