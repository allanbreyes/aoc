# frozen_string_literal: true

class Assembunny
  attr_reader :registers, :pc, :program

  def initialize(instructions)
    @program = parse(instructions)
    @registers = Hash.new(0)
    @pc = 0
  end

  # rubocop:disable Metrics/*
  def run!
    i = 0
    i += 1
    while @pc < @program.size
      op, *args = @program[@pc]

      case op
      when :nop
        # Do nothing
      when :inc, :dec, :tgl
        x, *rest = args
        raise "Invalid arguments: #{rest}" unless !x.nil? && rest.empty?

        send(op, x)

      when :cpy, :jnz
        x, y, *rest = args
        raise "Invalid arguments: #{rest}" unless !x.nil? && !y.nil? && rest.empty?

        send(op, x, y)

      when :out
        x, *rest = args
        raise "Invalid arguments: #{rest}" unless !x.nil? && rest.empty?

        yield get(x) if block_given?

      when :muladd
        x, y, z, *rest = args
        raise "Invalid arguments: #{rest}" unless !x.nil? && !y.nil? && !z.nil? && rest.empty?

        send(op, x, y, z)

      else
        raise "Unknown instruction: #{op}"
      end
      @pc += 1
      i += 1
    end
  end

  # rubocop:disable Metrics/*
  def collapse!
    # Find patterns of the form:
    #   cpy b c
    #   inc a
    #   dec c
    #   jnz c -2
    #   dec d
    #   jnz d -5
    #
    # and replace with custom instructions:
    #   muladd b d a
    #   nop (x5)
    @program.each_cons(6).with_index do |ins, i|
      next unless ins.map(&:first) == %i[cpy inc dec jnz dec jnz]

      # cpy b c
      _, x, c = ins[0]

      # inc a
      _, reg = ins[1]

      # dec c
      next unless ins[2][1] == c

      # jnz c -2
      next unless ins[3][1] == c && ins[3][2] == -2

      # dec d
      _, y = ins[4]

      # jnz d -5
      next unless ins[5][1] == y && ins[5][2] == -5

      @program[i] = [:muladd, x, y, reg]
      5.times { |j| @program[i + j + 1] = [:nop] }
    end
  end

  def get(x)
    x.is_a?(Integer) ? x : @registers[x]
  end

  def cpy(x, reg)
    return unless reg.is_a?(Symbol)

    @registers[reg] = get(x)
  end

  def inc(reg)
    return unless reg.is_a?(Symbol)

    @registers[reg] += 1
  end

  def dec(reg)
    return unless reg.is_a?(Symbol)

    @registers[reg] -= 1
  end

  def jnz(x, y)
    @pc += get(y) - 1 unless get(x).zero?
  end

  def tgl(x)
    target = x.is_a?(Integer) ? @pc + x : @pc + @registers[x]
    return if target.negative? || target >= @program.size

    op, *args = @program[target]
    @program[target] = case op
                       when :inc then [:dec, *args]
                       when :dec, :tgl, :out then [:inc, *args]
                       when :jnz then [:cpy, *args]
                       when :cpy then [:jnz, *args]
                       end
  end

  # Custom instructions
  def muladd(x, y, reg)
    # Multiply x and y and add the result to reg.
    return unless reg.is_a?(Symbol)

    @registers[reg] += get(x) * get(y)
  end

  def nop; end

  private

  def parse(instructions)
    instructions.strip.split("\n").map do |line|
      line.split.map { |x| x.match(/^[-\d]+/) ? x.to_i : x.to_sym }
    end
  end
end
