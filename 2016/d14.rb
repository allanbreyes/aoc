# frozen_string_literal: true

require 'digest/md5'

class D14
  def initialize(input)
    @input = input
    @seed = parse
    @memo = {}
  end

  def part1
    mine.last
  end

  def part2
    mine(stretched: true).last
  end

  def mine(stretched: false)
    keys = []
    i = 0
    while keys.length < 64
      md5 = stretched ? stretch(i) : hash(i)
      c = repeat?(3, md5)
      if c
        (1..1000).each do |j|
          md5 = stretched ? stretch(i + j) : hash(i + j)
          next unless md5.include?(c * 5)

          keys << i
          break
        end
      end

      i += 1
    end
    keys
  end

  def hash(k)
    return @memo[k] if @memo.key?(k)

    @memo[k] = Digest::MD5.hexdigest("#{@seed}#{k}")
  end

  def stretch(k)
    return @memo[[k, :stretch]] if @memo.key?([k, :stretch])

    h = hash(k)
    2016.times do
      h = Digest::MD5.hexdigest(h)
    end
    @memo[[k, :stretch]] = h
  end

  def repeat?(n, md5)
    md5.chars.each_cons(n) do |chars|
      return chars.first if chars.all? { |c| c == chars.first }
    end
  end

  def parse
    @input.strip
  end
end
