# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Snn (Style Name Notation)
#
# This test suite verifies the validation, parsing, and comparison logic
# of the Sashite::Snn::Name class in accordance with the SNN specification v1.0.0.

require_relative "lib/sashite-snn"

def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Snn (Style Name Notation) v1.0.0"
puts

run_test("Valid SNN strings are accepted") do
  valid_names = [
    "Chess", "Shogi", "Xiangqi", "Makruk",
    "Chess960", "Minishogi", "Go9x9", "Janggi", "Sittuyin", "Capablanca10x8"
  ]

  valid_names.each do |name|
    raise "#{name.inspect} should be valid" unless Sashite::Snn.valid?(name)
    parsed = Sashite::Snn.parse(name)
    raise "Parsed value mismatch" unless parsed.to_s == name
    raise "Parsed value should be frozen" unless parsed.frozen?
  end
end

run_test("Invalid SNN strings are rejected") do
  invalid_names = [
    "", "chess", "9x9Go", "Shōgi", "象棋", "♔Chess", "1stChess", " Chess",
    "Chess ", "CHESS", "MiniShogi", "shogi960", "chess960", "A_B", "Go-9", nil, 123
  ]

  invalid_names.each do |name|
    valid = Sashite::Snn.valid?(name)
    raise "#{name.inspect} should be invalid" if valid

    begin
      Sashite::Snn.parse(name)
      raise "Parsing should fail for #{name.inspect}"
    rescue ArgumentError
      # expected
    end
  end
end

run_test("Equality and hashing of names") do
  name1 = Sashite::Snn.parse("Shogi")
  name2 = Sashite::Snn.parse("Shogi")
  name3 = Sashite::Snn.parse("Chess")

  raise "Names should be equal" unless name1 == name2
  raise "Names should have same hash" unless name1.hash == name2.hash
  raise "Names should not be equal" if name1 == name3

  set = [name1, name2, name3].uniq
  raise "Set should contain 2 unique names" unless set.size == 2
end

run_test("String and symbol inputs are supported") do
  name1 = Sashite::Snn.name("Xiangqi")
  name2 = Sashite::Snn.name(:Xiangqi)

  raise "String and symbol inputs should be equal" unless name1 == name2
  raise "Should stringify correctly" unless name1.to_s == "Xiangqi"
end

run_test("Frozen objects are immutable") do
  name = Sashite::Snn.parse("Makruk")

  raise "Name should be frozen" unless name.frozen?
  raise "Internal value should be frozen" unless name.value.frozen?
end

puts
puts "All SNN v1.0.0 tests passed!"
puts
