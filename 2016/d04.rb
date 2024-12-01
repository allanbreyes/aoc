# frozen_string_literal: true

LETTERS = ('a'..'z').map(&:to_s).freeze

class D04
  def initialize(input)
    @input = input
  end

  def part1
    sum = 0
    parse.each do |parts, sector, checksum|
      sum += sector if top(5, parts.join) == checksum
    end
    sum
  end

  def part2
    parse.each do |parts, sector, _|
      message = parts.map { |part| shift sector, part }.join(' ')
      return sector if message == 'northpole object storage'
    end
    nil
  end

  def shift(n, str)
    str.chars.map { |c| ((c.ord - 'a'.ord + n) % 26) + 'a'.ord }.map(&:chr).join
  end

  def top(n, str)
    counts = str.chars.sort.each_with_object({}) do |char, acc|
      acc[char] = 0 if acc[char].nil?
      acc[char] += 1
    end
    counts.sort_by { |k, v| [-v, k] }[...n].map { |item| item[0] }.join
  end

  def parse
    @input.strip.split("\n")
          .map { |row| row[...-1].split('[') }
          .map do |slug, checksum|
      parts = slug.split('-')
      [parts[...-1], parts[-1].to_i, checksum]
    end
  end
end
