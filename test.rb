# frozen_string_literal: true

require "simplecov"
SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Snn (Style Name Notation)
#
# Tests the SNN implementation for Ruby, covering validation,
# style creation, player association, and format compliance
# according to the SNN specification v1.0.0.
#
# This test assumes the existence of:
# - lib/sashite-snn.rb

require_relative "lib/sashite-snn"

# Helper function to run a test and report errors
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
puts "Tests for Sashite::Snn (Style Name Notation)"
puts

# Test module-level validation method
run_test("Module validation accepts valid SNN strings") do
  valid_styles = %w[CHESS chess SHOGI shogi XIANGQI xiangqi CHESS960 chess960 MAKRUK makruk JANGGI janggi MINISHOGI
                    minishogi A a Z z A1 a1 Z9 z9]

  valid_styles.each do |style|
    raise "#{style.inspect} should be valid" unless Sashite::Snn.valid?(style)
  end
end

run_test("Module validation rejects invalid SNN strings") do
  invalid_styles = ["", "Chess", "CHESS-960", "9CHESS", "chess_variant", "chess-960", " CHESS", "CHESS ", "Chess960",
                    "A-Z", "a_b", "123", "ABC-", "abc+"]

  invalid_styles.each do |style|
    raise "#{style.inspect} should be invalid" if Sashite::Snn.valid?(style)
  end
end

run_test("Module validation handles non-string input") do
  non_strings = [nil, 123, :CHESS, [], {}]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Snn.valid?(input)
  end
end

run_test("Module convenience method creates style objects") do
  style = Sashite::Snn.style("CHESS")

  raise "Should return Style instance" unless style.is_a?(Sashite::Snn::Style)
  raise "Should have correct identifier" unless style.identifier == "CHESS"
end

# Test Style class initialization
run_test("Style creation with valid identifiers") do
  valid_styles = %w[CHESS chess SHOGI960 minishogi A a Z9 z1]

  valid_styles.each do |identifier|
    style = Sashite::Snn::Style.new(identifier)
    raise "Should create style for #{identifier.inspect}" unless style.identifier == identifier
  end
end

run_test("Style creation rejects invalid identifiers") do
  invalid_styles = ["", "Chess", "CHESS-960", "9CHESS"]

  invalid_styles.each do |identifier|
    Sashite::Snn::Style.new(identifier)
    raise "Should have raised ArgumentError for #{identifier.inspect}"
  rescue ArgumentError => e
    raise "Wrong error message" unless e.message.include?("Invalid SNN format")
  end
end

run_test("Style.parse method works correctly") do
  style = Sashite::Snn::Style.parse("CHESS")

  raise "Should return Style instance" unless style.is_a?(Sashite::Snn::Style)
  raise "Should have correct identifier" unless style.identifier == "CHESS"
end

# Test player association methods
run_test("First player detection (uppercase styles)") do
  first_player_styles = %w[CHESS SHOGI XIANGQI MAKRUK CHESS960 A Z Z9]

  first_player_styles.each do |identifier|
    style = Sashite::Snn::Style.new(identifier)
    raise "#{identifier} should be first player" unless style.first_player?
    raise "#{identifier} should be uppercase" unless style.uppercase?
    raise "#{identifier} should not be second player" if style.second_player?
    raise "#{identifier} should not be lowercase" if style.lowercase?
  end
end

run_test("Second player detection (lowercase styles)") do
  second_player_styles = %w[chess shogi xiangqi makruk chess960 a z z9]

  second_player_styles.each do |identifier|
    style = Sashite::Snn::Style.new(identifier)
    raise "#{identifier} should be second player" unless style.second_player?
    raise "#{identifier} should be lowercase" unless style.lowercase?
    raise "#{identifier} should not be first player" if style.first_player?
    raise "#{identifier} should not be uppercase" if style.uppercase?
  end
end

# Test conversion methods
run_test("String conversion") do
  style = Sashite::Snn::Style.new("CHESS")

  raise "to_s should return identifier" unless style.to_s == "CHESS"
  raise "String conversion should work" unless "#{style}" == "CHESS"
end

run_test("Symbol conversion") do
  style = Sashite::Snn::Style.new("CHESS")

  raise "to_sym should return symbol" unless style.to_sym == :CHESS

  lowercase_style = Sashite::Snn::Style.new("chess960")
  raise "to_sym should work for lowercase" unless lowercase_style.to_sym == :chess960
end

run_test("Inspect method") do
  style = Sashite::Snn::Style.new("CHESS")
  inspect_string = style.inspect

  raise "Inspect should include class name" unless inspect_string.include?("Sashite::Snn::Style")
  raise "Inspect should include identifier" unless inspect_string.include?('"CHESS"')
end

# Test equality and hashing
run_test("Equality comparison") do
  style1 = Sashite::Snn::Style.new("CHESS")
  style2 = Sashite::Snn::Style.new("CHESS")
  style3 = Sashite::Snn::Style.new("chess")

  raise "Same styles should be equal" unless style1 == style2
  raise "Same styles should be eql" unless style1.eql?(style2)
  raise "Different case styles should not be equal" if style1 == style3
  raise "Different objects should not be equal" if style1 == "CHESS"
end

run_test("Hash behavior") do
  style1 = Sashite::Snn::Style.new("CHESS")
  style2 = Sashite::Snn::Style.new("CHESS")
  style3 = Sashite::Snn::Style.new("chess")

  hash = { style1 => "first_player_chess" }
  hash[style2] = "still_first_player_chess"
  hash[style3] = "second_player_chess"

  raise "Same styles should have same hash" unless style1.hash == style2.hash
  raise "Hash should have 2 entries" unless hash.size == 2
  raise "Should retrieve by equivalent style" unless hash[style2] == "still_first_player_chess"
end

# Test immutability
run_test("Identifier immutability") do
  style = Sashite::Snn::Style.new("CHESS")

  begin
    style.identifier << "EXTRA"
    raise "Should not be able to modify frozen identifier"
  rescue FrozenError
    # Expected behavior
  end
end

run_test("Style freeze behavior") do
  style = Sashite::Snn::Style.new("CHESS")
  frozen_style = style.freeze

  raise "Freeze should return self" unless frozen_style.equal?(style)
  raise "Style should be frozen" unless style.frozen?
end

# Test cross-style gaming scenarios
run_test("Cross-style game setup") do
  first_player = Sashite::Snn::Style.new("CHESS")
  second_player = Sashite::Snn::Style.new("makruk")

  raise "First player should use uppercase" unless first_player.first_player?
  raise "Second player should use lowercase" unless second_player.second_player?
  raise "Styles should be different" unless first_player != second_player

  # Simulate game configuration
  game_config = {
    first_player.to_sym  => { pieces: :western, board: :"8x8" },
    second_player.to_sym => { pieces: :thai, board: :"8x8" }
  }

  raise "Should have 2 configurations" unless game_config.size == 2
  raise "First player config should exist" unless game_config.key?(:CHESS)
  raise "Second player config should exist" unless game_config.key?(:makruk)
end

# Test variant styles
run_test("Chess variant styles") do
  variants = {
    "CHESS960"  => true,   # First player Chess960
    "chess960"  => false,  # Second player Chess960
    "CHESSKING" => true,  # First player King of the Hill
    "chessking" => false, # Second player King of the Hill
    "MINISHOGI" => true,  # First player Mini Shogi
    "minishogi" => false  # Second player Mini Shogi
  }

  variants.each do |identifier, is_first_player|
    style = Sashite::Snn::Style.new(identifier)
    if is_first_player
      raise "#{identifier} should be first player" unless style.first_player?
    else
      raise "#{identifier} should be second player" unless style.second_player?
    end
  end
end

# Test edge cases and boundary conditions
run_test("Single character styles") do
  single_chars = %w[A B C X Y Z a b c x y z]

  single_chars.each do |char|
    style = Sashite::Snn::Style.new(char)
    raise "Single char #{char} should work" unless style.identifier == char
  end
end

run_test("Alphanumeric styles") do
  alphanumeric = %w[A1 B2 C3 X9 Y0 Z123 a1 b2 c3 x9 y0 z123]

  alphanumeric.each do |identifier|
    style = Sashite::Snn::Style.new(identifier)
    raise "Alphanumeric #{identifier} should work" unless style.identifier == identifier
  end
end

run_test("Case sensitivity preservation") do
  uppercase_style = Sashite::Snn::Style.new("CHESS")
  lowercase_style = Sashite::Snn::Style.new("chess")

  raise "Uppercase should remain uppercase" unless uppercase_style.to_s == "CHESS"
  raise "Lowercase should remain lowercase" unless lowercase_style.to_s == "chess"
  raise "Different cases should create different styles" unless uppercase_style != lowercase_style
end

puts
puts "All SNN tests passed!"
puts
