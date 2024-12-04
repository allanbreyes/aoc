# frozen_string_literal: true

class Rule
  def initialize(from:, low:, high:)
    @from = from
    @low = low
    @high = high
  end

  def run!
    low, high = @from.minmax
    @low.add(low)
    @high.add(high)
    @from.clear
  end

  def target?
    @from.minmax == [17, 61]
  end
end

class D10
  def initialize(input)
    @input = input
  end

  def part1
    bot, = simulate
    bot
  end

  def part2
    _, bins = simulate
    (0..2).map { |i| bins[[:output, i]].first }.reduce(:*)
  end

  def simulate
    bins, rules = parse
    target = nil

    loop do
      changed = false
      bins.each do |(type, bot), chips|
        next if type != :bot || chips.size < 2

        rule = rules[bot]
        target = bot if rule.target?
        rules[bot].run!
        changed = true
      end

      break unless changed
    end

    [target, bins]
  end

  # NOTE: this is pretty gross! I'm sure there's a more idiomatic way, but I'm
  # short on time and motivation.
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def parse
    bins = {}
    rules = {}

    @input.strip.split("\n").each do |line|
      case line
      when /^value (\d+) goes to bot (\d+)$/
        val = ::Regexp.last_match(1).to_i
        bot = ::Regexp.last_match(2).to_i

        bins[[:bot, bot]] = Set[] if bins[[:bot, bot]].nil?
        bins[[:bot, bot]].add(val)
      when /^bot (\d+) gives low to (\w+) (\d+) and high to (\w+) (\d+)$/
        bot = ::Regexp.last_match(1).to_i
        low_type = ::Regexp.last_match(2).to_sym
        low_to = ::Regexp.last_match(3).to_i
        high_type = ::Regexp.last_match(4).to_sym
        high_to = ::Regexp.last_match(5).to_i

        bins[[:bot, bot]] = Set[] if bins[[:bot, bot]].nil?
        bins[[low_type, low_to]] = Set[] if bins[[low_type, low_to]].nil?
        bins[[high_type, high_to]] = Set[] if bins[[high_type, high_to]].nil?

        rules[bot] = Rule.new(from: bins[[:bot, bot]], low: bins[[low_type, low_to]], high: bins[[high_type, high_to]])
      else
        raise "Invalid input: #{line}"
      end
    end

    [bins, rules]
  end
end
