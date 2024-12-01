# frozen_string_literal: true

require 'pry'
require 'digest/md5'

class D05
  def initialize(input)
    @input = input.strip
  end

  def part1
    passwd = []
    mine do |hash|
      passwd << hash[5]
      break if passwd.size == 8
    end
    passwd.join
  end

  def part2
    passwd = Array.new(8)
    mine do |hash|
      pos = hash[5].to_i(16)
      next if pos > 7 || passwd[pos]

      passwd[pos] = hash[6]
      break if passwd.all?
    end
    passwd.join
  end

  def mine
    n = 0
    loop do
      Digest::MD5.hexdigest("#{@input}#{n}").tap do |hash|
        yield hash if hash.start_with?('00000')
      end
      n += 1
    end
  end
end
