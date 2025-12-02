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
    "GOLD", "silver", "LANCE", "general", "ADVISOR", "soldier",
    "KING^", "queen^", "ROOK^", "bishop^", "KNIGHT^", "pawn^",
    "+KING^", "+queen^", "+ROOK^", "+bishop^", "+KNIGHT^", "+pawn^",
    "-KING^", "-queen^", "-ROOK^", "-bishop^", "-KNIGHT^", "-pawn^",
    "GENERAL^", "gold^", "ADVISOR^", "soldier^"
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
    "+-KING", "-+KING", "++KING", "--KING", "+", "-", "king1", "Pawn",
    "^KING", "^king", "KING^^", "+^KING", "-^KING", "^+KING", "^-KING",
    "KI^NG", "K^ING", "^", "^^"
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

  # Enhanced terminal pieces
  enhanced_terminal = Sashite::Pnn.parse("+KING^")
  raise "Enhanced terminal piece should be enhanced" unless enhanced_terminal.enhanced?
  raise "Enhanced terminal piece should not be normal" if enhanced_terminal.normal?
  raise "Enhanced terminal piece should be terminal" unless enhanced_terminal.terminal?
  raise "Base name should be KING" unless enhanced_terminal.base_name == "KING"

  # Diminished pieces
  diminished = Sashite::Pnn.parse("-pawn")
  raise "Diminished piece should be diminished" unless diminished.diminished?
  raise "Diminished piece should not be normal" if diminished.normal?
  raise "Diminished piece should not be enhanced" if diminished.enhanced?
  raise "Base name should be pawn" unless diminished.base_name == "pawn"

  # Diminished terminal pieces
  diminished_terminal = Sashite::Pnn.parse("-pawn^")
  raise "Diminished terminal piece should be diminished" unless diminished_terminal.diminished?
  raise "Diminished terminal piece should not be normal" if diminished_terminal.normal?
  raise "Diminished terminal piece should be terminal" unless diminished_terminal.terminal?
  raise "Base name should be pawn" unless diminished_terminal.base_name == "pawn"

  # Normal pieces
  normal = Sashite::Pnn.parse("QUEEN")
  raise "Normal piece should be normal" unless normal.normal?
  raise "Normal piece should not be enhanced" if normal.enhanced?
  raise "Normal piece should not be diminished" if normal.diminished?
  raise "Base name should be QUEEN" unless normal.base_name == "QUEEN"

  # Normal terminal pieces
  normal_terminal = Sashite::Pnn.parse("QUEEN^")
  raise "Normal terminal piece should be normal" unless normal_terminal.normal?
  raise "Normal terminal piece should be terminal" unless normal_terminal.terminal?
  raise "Base name should be QUEEN" unless normal_terminal.base_name == "QUEEN"
end

run_test("Terminal marker detection works correctly") do
  # Terminal pieces
  terminal = Sashite::Pnn.parse("KING^")
  raise "Terminal piece should be terminal" unless terminal.terminal?
  raise "Base name should be KING" unless terminal.base_name == "KING"
  raise "Terminal piece value should include marker" unless terminal.to_s == "KING^"

  terminal_lower = Sashite::Pnn.parse("king^")
  raise "Lowercase terminal piece should be terminal" unless terminal_lower.terminal?
  raise "Base name should be king" unless terminal_lower.base_name == "king"

  # Non-terminal pieces
  non_terminal = Sashite::Pnn.parse("KING")
  raise "Non-terminal piece should not be terminal" if non_terminal.terminal?
  raise "Base name should be KING" unless non_terminal.base_name == "KING"
  raise "Non-terminal piece value should not include marker" unless non_terminal.to_s == "KING"

  # Combined with state modifiers
  enhanced_terminal = Sashite::Pnn.parse("+ROOK^")
  raise "Enhanced terminal should be enhanced" unless enhanced_terminal.enhanced?
  raise "Enhanced terminal should be terminal" unless enhanced_terminal.terminal?
  raise "Base name should be ROOK" unless enhanced_terminal.base_name == "ROOK"
  raise "Enhanced terminal value should be +ROOK^" unless enhanced_terminal.to_s == "+ROOK^"

  diminished_terminal = Sashite::Pnn.parse("-pawn^")
  raise "Diminished terminal should be diminished" unless diminished_terminal.diminished?
  raise "Diminished terminal should be terminal" unless diminished_terminal.terminal?
  raise "Base name should be pawn" unless diminished_terminal.base_name == "pawn"
  raise "Diminished terminal value should be -pawn^" unless diminished_terminal.to_s == "-pawn^"
end

run_test("Player assignment detection works correctly") do
  # First player pieces (uppercase)
  first_player = Sashite::Pnn.parse("ROOK")
  raise "Uppercase piece should be first player" unless first_player.first_player?
  raise "Uppercase piece should not be second player" if first_player.second_player?

  first_player_enhanced = Sashite::Pnn.parse("+BISHOP")
  raise "Enhanced uppercase piece should be first player" unless first_player_enhanced.first_player?
  raise "Enhanced uppercase piece should not be second player" if first_player_enhanced.second_player?

  first_player_terminal = Sashite::Pnn.parse("KING^")
  raise "Terminal uppercase piece should be first player" unless first_player_terminal.first_player?
  raise "Terminal uppercase piece should not be second player" if first_player_terminal.second_player?
  raise "Terminal uppercase piece should be terminal" unless first_player_terminal.terminal?

  first_player_enhanced_terminal = Sashite::Pnn.parse("+GENERAL^")
  raise "Enhanced terminal uppercase piece should be first player" unless first_player_enhanced_terminal.first_player?
  raise "Enhanced terminal uppercase piece should not be second player" if first_player_enhanced_terminal.second_player?
  raise "Enhanced terminal uppercase piece should be enhanced" unless first_player_enhanced_terminal.enhanced?
  raise "Enhanced terminal uppercase piece should be terminal" unless first_player_enhanced_terminal.terminal?

  # Second player pieces (lowercase)
  second_player = Sashite::Pnn.parse("knight")
  raise "Lowercase piece should be second player" unless second_player.second_player?
  raise "Lowercase piece should not be first player" if second_player.first_player?

  second_player_diminished = Sashite::Pnn.parse("-queen")
  raise "Diminished lowercase piece should be second player" unless second_player_diminished.second_player?
  raise "Diminished lowercase piece should not be first player" if second_player_diminished.first_player?

  second_player_terminal = Sashite::Pnn.parse("king^")
  raise "Terminal lowercase piece should be second player" unless second_player_terminal.second_player?
  raise "Terminal lowercase piece should not be first player" if second_player_terminal.first_player?
  raise "Terminal lowercase piece should be terminal" unless second_player_terminal.terminal?

  second_player_diminished_terminal = Sashite::Pnn.parse("-general^")
  raise "Diminished terminal lowercase piece should be second player" unless second_player_diminished_terminal.second_player?
  raise "Diminished terminal lowercase piece should not be first player" if second_player_diminished_terminal.first_player?
  raise "Diminished terminal lowercase piece should be diminished" unless second_player_diminished_terminal.diminished?
  raise "Diminished terminal lowercase piece should be terminal" unless second_player_diminished_terminal.terminal?
end

run_test("Base name comparison works correctly") do
  king_first = Sashite::Pnn.parse("KING")
  king_second = Sashite::Pnn.parse("king")
  king_enhanced = Sashite::Pnn.parse("+KING")
  king_diminished = Sashite::Pnn.parse("-king")
  king_terminal = Sashite::Pnn.parse("KING^")
  king_enhanced_terminal = Sashite::Pnn.parse("+KING^")
  king_diminished_terminal = Sashite::Pnn.parse("-king^")
  queen = Sashite::Pnn.parse("QUEEN")

  # Same base name comparisons
  raise "Same piece different player should have same base name" unless king_first.same_base_name?(king_second)
  raise "Same piece different state should have same base name" unless king_first.same_base_name?(king_enhanced)
  raise "Same piece different state and player should have same base name" unless king_first.same_base_name?(king_diminished)
  raise "Same piece with terminal marker should have same base name" unless king_first.same_base_name?(king_terminal)
  raise "Same piece with state and terminal should have same base name" unless king_first.same_base_name?(king_enhanced_terminal)
  raise "Same piece with different state and terminal should have same base name" unless king_first.same_base_name?(king_diminished_terminal)

  # Different base name comparisons
  raise "Different pieces should not have same base name" if king_first.same_base_name?(queen)
  raise "Different pieces should not have same base name" if king_second.same_base_name?(queen)
  raise "Different pieces with terminal should not have same base name" if king_terminal.same_base_name?(queen)
end

run_test("Equality and hashing of names") do
  name1 = Sashite::Pnn.parse("KING")
  name2 = Sashite::Pnn.parse("KING")
  name3 = Sashite::Pnn.parse("king")
  name4 = Sashite::Pnn.parse("+KING")
  name5 = Sashite::Pnn.parse("KING^")
  name6 = Sashite::Pnn.parse("KING^")
  name7 = Sashite::Pnn.parse("+KING^")

  raise "Names should be equal" unless name1 == name2
  raise "Names should have same hash" unless name1.hash == name2.hash
  raise "Names should not be equal (different case)" if name1 == name3
  raise "Names should not be equal (different state)" if name1 == name4
  raise "Names should not be equal (different terminal)" if name1 == name5
  raise "Terminal names should be equal" unless name5 == name6
  raise "Terminal names should have same hash" unless name5.hash == name6.hash
  raise "Names should not be equal (different state and terminal)" if name1 == name7

  set = [name1, name2, name3, name4, name5, name6, name7].uniq
  raise "Set should contain 5 unique names" unless set.size == 5
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

  # Test with terminal markers
  terminal1 = Sashite::Pnn.name("KING^")
  terminal2 = Sashite::Pnn.name(:"KING^")

  raise "String and symbol inputs with terminal should be equal" unless terminal1 == terminal2
  raise "Should stringify correctly with terminal" unless terminal1.to_s == "KING^"

  # Test with both state and terminal
  combined1 = Sashite::Pnn.name("+ROOK^")
  combined2 = Sashite::Pnn.name(:"+ROOK^")

  raise "String and symbol inputs with state and terminal should be equal" unless combined1 == combined2
  raise "Should stringify correctly with state and terminal" unless combined1.to_s == "+ROOK^"
end

run_test("Frozen objects are immutable") do
  name = Sashite::Pnn.parse("ROOK")

  raise "Name should be frozen" unless name.frozen?
  raise "Internal value should be frozen" unless name.value.frozen?

  # Test with state modifiers
  enhanced = Sashite::Pnn.parse("+pawn")
  raise "Enhanced name should be frozen" unless enhanced.frozen?
  raise "Enhanced internal value should be frozen" unless enhanced.value.frozen?

  # Test with terminal markers
  terminal = Sashite::Pnn.parse("KING^")
  raise "Terminal name should be frozen" unless terminal.frozen?
  raise "Terminal internal value should be frozen" unless terminal.value.frozen?

  # Test with both
  combined = Sashite::Pnn.parse("+ROOK^")
  raise "Combined name should be frozen" unless combined.frozen?
  raise "Combined internal value should be frozen" unless combined.value.frozen?
end

run_test("Complex piece names work correctly") do
  complex_names = [
    "GOLD", "silver", "LANCE", "general", "ADVISOR", "soldier",
    "+SILVER", "-PAWN", "+GENERAL", "-SOLDIER",
    "KING^", "queen^", "GENERAL^", "advisor^",
    "+ROOK^", "-pawn^", "+BISHOP^", "-knight^"
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

    # Test terminal detection
    if name.end_with?("^")
      raise "#{name.inspect} should be terminal" unless parsed.terminal?
    else
      raise "#{name.inspect} should not be terminal" if parsed.terminal?
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

run_test("Base name extraction works correctly") do
  # Without modifiers
  simple = Sashite::Pnn.parse("KING")
  raise "Base name should be KING" unless simple.base_name == "KING"

  # With state modifier only
  enhanced = Sashite::Pnn.parse("+ROOK")
  raise "Base name should be ROOK" unless enhanced.base_name == "ROOK"

  diminished = Sashite::Pnn.parse("-pawn")
  raise "Base name should be pawn" unless diminished.base_name == "pawn"

  # With terminal marker only
  terminal = Sashite::Pnn.parse("QUEEN^")
  raise "Base name should be QUEEN" unless terminal.base_name == "QUEEN"

  terminal_lower = Sashite::Pnn.parse("bishop^")
  raise "Base name should be bishop" unless terminal_lower.base_name == "bishop"

  # With both state modifier and terminal marker
  enhanced_terminal = Sashite::Pnn.parse("+GENERAL^")
  raise "Base name should be GENERAL" unless enhanced_terminal.base_name == "GENERAL"

  diminished_terminal = Sashite::Pnn.parse("-knight^")
  raise "Base name should be knight" unless diminished_terminal.base_name == "knight"
end

run_test("All modifier combinations are valid") do
  combinations = [
    ["KING", false, false, false],
    ["king", false, false, false],
    ["KING^", false, false, true],
    ["king^", false, false, true],
    ["+KING", true, false, false],
    ["+king", true, false, false],
    ["+KING^", true, false, true],
    ["+king^", true, false, true],
    ["-KING", false, true, false],
    ["-king", false, true, false],
    ["-KING^", false, true, true],
    ["-king^", false, true, true]
  ]

  combinations.each do |name, should_be_enhanced, should_be_diminished, should_be_terminal|
    parsed = Sashite::Pnn.parse(name)

    if should_be_enhanced
      raise "#{name} should be enhanced" unless parsed.enhanced?
    else
      raise "#{name} should not be enhanced" if parsed.enhanced?
    end

    if should_be_diminished
      raise "#{name} should be diminished" unless parsed.diminished?
    else
      raise "#{name} should not be diminished" if parsed.diminished?
    end

    if should_be_terminal
      raise "#{name} should be terminal" unless parsed.terminal?
    else
      raise "#{name} should not be terminal" if parsed.terminal?
    end
  end
end

puts
puts "All PNN v1.0.0 tests passed!"
puts
