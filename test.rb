# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Pnn (Piece Name Notation)
#
# This test suite verifies the validation, parsing, and comparison logic
# of the Sashite::Pnn::Name class in accordance with the PNN specification v1.0.0.

require_relative "lib/sashite-pnn"

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
puts "Tests for Sashite::Pnn (Piece Name Notation) v1.0.0"
puts

run_test("Valid PNN strings are accepted") do
  valid_names = [
    "KING", "queen", "ROOK", "bishop", "KNIGHT", "pawn",
    "+KING", "+queen", "+ROOK", "+bishop", "+KNIGHT", "+pawn",
    "-KING", "-queen", "-ROOK", "-bishop", "-KNIGHT", "-pawn",
    "GOLD", "silver", "LANCE", "general", "ADVISOR", "soldier"
  ]

  valid_names.each do |name|
    raise "#{name.inspect} should be valid" unless Sashite::Pnn.valid?(name)
    parsed = Sashite::Pnn.parse(name)
    raise "Parsed value mismatch" unless parsed.to_s == name
    raise "Parsed value should be frozen" unless parsed.frozen?
  end
end

run_test("Invalid PNN strings are rejected") do
  invalid_names = [
    "", "King", "KING1", "1KING", "KiNg", "king-", "KING+", " KING",
    "KING ", "K1NG", "KI_NG", "KI-NG", "KI+NG", "王", "♔KING", nil, 123,
    "+-KING", "-+KING", "++KING", "--KING", "+", "-", "king1", "Pawn"
  ]

  invalid_names.each do |name|
    valid = Sashite::Pnn.valid?(name)
    raise "#{name.inspect} should be invalid" if valid

    begin
      Sashite::Pnn.parse(name)
      raise "Parsing should fail for #{name.inspect}"
    rescue ArgumentError
      # expected
    end
  end
end

run_test("State modifier detection works correctly") do
  # Enhanced pieces
  enhanced = Sashite::Pnn.parse("+KING")
  raise "Enhanced piece should be enhanced" unless enhanced.enhanced?
  raise "Enhanced piece should not be normal" if enhanced.normal?
  raise "Enhanced piece should not be diminished" if enhanced.diminished?
  raise "Base name should be KING" unless enhanced.base_name == "KING"

  # Diminished pieces
  diminished = Sashite::Pnn.parse("-pawn")
  raise "Diminished piece should be diminished" unless diminished.diminished?
  raise "Diminished piece should not be normal" if diminished.normal?
  raise "Diminished piece should not be enhanced" if diminished.enhanced?
  raise "Base name should be pawn" unless diminished.base_name == "pawn"

  # Normal pieces
  normal = Sashite::Pnn.parse("QUEEN")
  raise "Normal piece should be normal" unless normal.normal?
  raise "Normal piece should not be enhanced" if normal.enhanced?
  raise "Normal piece should not be diminished" if normal.diminished?
  raise "Base name should be QUEEN" unless normal.base_name == "QUEEN"
end

run_test("Player assignment detection works correctly") do
  # First player pieces (uppercase)
  first_player = Sashite::Pnn.parse("ROOK")
  raise "Uppercase piece should be first player" unless first_player.first_player?
  raise "Uppercase piece should not be second player" if first_player.second_player?

  first_player_enhanced = Sashite::Pnn.parse("+BISHOP")
  raise "Enhanced uppercase piece should be first player" unless first_player_enhanced.first_player?
  raise "Enhanced uppercase piece should not be second player" if first_player_enhanced.second_player?

  # Second player pieces (lowercase)
  second_player = Sashite::Pnn.parse("knight")
  raise "Lowercase piece should be second player" unless second_player.second_player?
  raise "Lowercase piece should not be first player" if second_player.first_player?

  second_player_diminished = Sashite::Pnn.parse("-queen")
  raise "Diminished lowercase piece should be second player" unless second_player_diminished.second_player?
  raise "Diminished lowercase piece should not be first player" if second_player_diminished.first_player?
end

run_test("Base name comparison works correctly") do
  king_first = Sashite::Pnn.parse("KING")
  king_second = Sashite::Pnn.parse("king")
  king_enhanced = Sashite::Pnn.parse("+KING")
  king_diminished = Sashite::Pnn.parse("-king")
  queen = Sashite::Pnn.parse("QUEEN")

  # Same base name comparisons
  raise "Same piece different player should have same base name" unless king_first.same_base_name?(king_second)
  raise "Same piece different state should have same base name" unless king_first.same_base_name?(king_enhanced)
  raise "Same piece different state and player should have same base name" unless king_first.same_base_name?(king_diminished)

  # Different base name comparisons
  raise "Different pieces should not have same base name" if king_first.same_base_name?(queen)
  raise "Different pieces should not have same base name" if king_second.same_base_name?(queen)
end

run_test("Equality and hashing of names") do
  name1 = Sashite::Pnn.parse("KING")
  name2 = Sashite::Pnn.parse("KING")
  name3 = Sashite::Pnn.parse("king")
  name4 = Sashite::Pnn.parse("+KING")

  raise "Names should be equal" unless name1 == name2
  raise "Names should have same hash" unless name1.hash == name2.hash
  raise "Names should not be equal (different case)" if name1 == name3
  raise "Names should not be equal (different state)" if name1 == name4

  set = [name1, name2, name3, name4].uniq
  raise "Set should contain 3 unique names" unless set.size == 3
end

run_test("String and symbol inputs are supported") do
  name1 = Sashite::Pnn.name("BISHOP")
  name2 = Sashite::Pnn.name(:BISHOP)

  raise "String and symbol inputs should be equal" unless name1 == name2
  raise "Should stringify correctly" unless name1.to_s == "BISHOP"

  # Test with state modifiers
  enhanced1 = Sashite::Pnn.name("+queen")
  enhanced2 = Sashite::Pnn.name(:"+queen")

  raise "String and symbol inputs with state should be equal" unless enhanced1 == enhanced2
  raise "Should stringify correctly with state" unless enhanced1.to_s == "+queen"
end

run_test("Frozen objects are immutable") do
  name = Sashite::Pnn.parse("ROOK")

  raise "Name should be frozen" unless name.frozen?
  raise "Internal value should be frozen" unless name.value.frozen?

  # Test with state modifiers
  enhanced = Sashite::Pnn.parse("+pawn")
  raise "Enhanced name should be frozen" unless enhanced.frozen?
  raise "Enhanced internal value should be frozen" unless enhanced.value.frozen?
end

run_test("Complex piece names work correctly") do
  complex_names = [
    "GOLD", "silver", "LANCE", "general", "ADVISOR", "soldier",
    "+SILVER", "-PAWN", "+GENERAL", "-SOLDIER"
  ]

  complex_names.each do |name|
    parsed = Sashite::Pnn.parse(name)
    raise "Complex name #{name.inspect} should parse correctly" unless parsed.to_s == name

    # Test state detection
    if name.start_with?("+")
      raise "#{name.inspect} should be enhanced" unless parsed.enhanced?
      raise "#{name.inspect} should not be normal" if parsed.normal?
    elsif name.start_with?("-")
      raise "#{name.inspect} should be diminished" unless parsed.diminished?
      raise "#{name.inspect} should not be normal" if parsed.normal?
    else
      raise "#{name.inspect} should be normal" unless parsed.normal?
      raise "#{name.inspect} should not be enhanced" if parsed.enhanced?
    end

    # Test player detection
    base = parsed.base_name
    if base == base.upcase
      raise "#{name.inspect} should be first player" unless parsed.first_player?
    else
      raise "#{name.inspect} should be second player" unless parsed.second_player?
    end
  end
end

puts
puts "All PNN v1.0.0 tests passed!"
puts
