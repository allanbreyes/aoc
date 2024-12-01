# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.pattern = '*_test.rb'
end

RuboCop::RakeTask.new do |t|
  t.requires << 'rubocop-minitest'
  t.requires << 'rubocop-rake'
end

task default: %w[test rubocop:autocorrect]

desc "Run a specific day's solution"
task :day, [:day] do |_t, args|
  day = if args[:day].nil?
          Dir['d*.rb'].map { |x| x[1..2] }.max
        else
          Integer(args[:day]).to_s.rjust(2, '0')
        end

  require_relative "d#{day}"
  solver = Object.const_get("D#{day}").new(File.read("inputs/#{day}.txt"))
  puts "Day #{day}, Part 1: #{solver.part1}"
  puts "Day #{day}, Part 2: #{solver.part2}"
end

desc "Generate a new day's solution"
task :new do
  day = (Dir['d*.rb'].map { |x| x[1..2] }.max.to_i + 1).to_s.rjust(2, '0')
  solver = File.read('d00.rb').gsub('00', day)
  tester = File.read('d00_test.rb').gsub('00', day)
  File.write("d#{day}.rb", solver)
  File.write("d#{day}_test.rb", tester)
  File.write("inputs/#{day}.txt", '')
  puts "Generated day #{day}"
end
