# frozen_string_literal: true

# Tests for Sashite::Snn (Style Name Notation)
#
# Tests the SNN implementation for Ruby, focusing on the modern object-oriented API
# with the Style class using symbol-based attributes and the minimal module interface.

require_relative "lib/sashite-snn"
require "set"

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

# Test basic validation (module level)
run_test("Module SNN validation accepts valid notations") do
  valid_snns = [
    "CHESS", "chess", "SHOGI", "shogi", "XIANGQI", "xiangqi",
    "A", "a", "Z", "z", "CHESS960", "chess960",
    "KOTH", "koth", "THREECHECK", "threecheck",
    "ABC123", "abc123", "A1B2C3", "a1b2c3"
  ]

  valid_snns.each do |snn|
    raise "#{snn.inspect} should be valid" unless Sashite::Snn.valid?(snn)
  end
end

run_test("Module SNN validation rejects invalid notations") do
  invalid_snns = [
    "", "Chess", "CHESS chess", "123", "123CHESS", "1CHESS",
    "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
    " CHESS", "CHESS ", "Che ss", "CHE-SS", "CHE_SS",
    "ChEsS", "chESs", "CheSs", "CHESS-960", "CHESS_960",
    "chess+", "chess-", "+chess", "-chess"
  ]

  invalid_snns.each do |snn|
    raise "#{snn.inspect} should be invalid" if Sashite::Snn.valid?(snn)
  end
end

run_test("Module SNN validation handles non-string input") do
  non_strings = [nil, 123, :chess, [], {}, true, false, 1.5]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Snn.valid?(input)
  end
end

# Test module parse method delegates to Style
run_test("Module parse delegates to Style class") do
  snn_string = "CHESS"
  style = Sashite::Snn.parse(snn_string)

  raise "parse should return Style instance" unless style.is_a?(Sashite::Snn::Style)
  raise "style should have correct SNN string" unless style.to_s == snn_string
end

# Test module style factory method
run_test("Module style factory method creates correct instances") do
  style = Sashite::Snn.style(:Chess, :first)

  raise "style factory should return Style instance" unless style.is_a?(Sashite::Snn::Style)
  raise "style should have correct name" unless style.name == :Chess
  raise "style should have correct side" unless style.side == :first
  raise "style should have correct SNN string" unless style.to_s == "CHESS"
end

# Test the Style class with new symbol-based API
run_test("Style.parse creates correct instances with symbol attributes") do
  test_cases = {
    "CHESS" => { name: :Chess, side: :first },
    "chess" => { name: :Chess, side: :second },
    "SHOGI" => { name: :Shogi, side: :first },
    "shogi" => { name: :Shogi, side: :second },
    "CHESS960" => { name: :Chess960, side: :first },
    "chess960" => { name: :Chess960, side: :second }
  }

  test_cases.each do |snn_string, expected|
    style = Sashite::Snn.parse(snn_string)

    raise "#{snn_string}: wrong name" unless style.name == expected[:name]
    raise "#{snn_string}: wrong side" unless style.side == expected[:side]
  end
end

run_test("Style constructor with symbol parameters") do
  test_cases = [
    [:Chess, :first, "CHESS"],
    [:Chess, :second, "chess"],
    [:Shogi, :first, "SHOGI"],
    [:Shogi, :second, "shogi"],
    [:Chess960, :first, "CHESS960"],
    [:Chess960, :second, "chess960"]
  ]

  test_cases.each do |name, side, expected_snn|
    style = Sashite::Snn::Style.new(name, side)

    raise "name should be #{name}" unless style.name == name
    raise "side should be #{side}" unless style.side == side
    raise "SNN string should be #{expected_snn}" unless style.to_s == expected_snn
  end
end

run_test("Style to_s returns correct SNN string") do
  test_cases = [
    [:Chess, :first, "CHESS"],
    [:Chess, :second, "chess"],
    [:Shogi, :first, "SHOGI"],
    [:Shogi, :second, "shogi"],
    [:Chess960, :first, "CHESS960"],
    [:Chess960, :second, "chess960"]
  ]

  test_cases.each do |name, side, expected|
    style = Sashite::Snn::Style.new(name, side)
    result = style.to_s

    raise "#{name}, #{side} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Style side mutations return new instances") do
  style = Sashite::Snn::Style.new(:Chess, :first)

  # Test flip
  flipped = style.flip
  raise "flip should return new instance" if flipped.equal?(style)
  raise "flipped style should have opposite side" unless flipped.side == :second
  raise "flipped style should have same name" unless flipped.name == style.name
  raise "original style should be unchanged" unless style.side == :first
end

run_test("Style attribute transformations") do
  style = Sashite::Snn::Style.new(:Chess, :first)

  # Test with_name
  shogi = style.with_name(:Shogi)
  raise "with_name should return new instance" if shogi.equal?(style)
  raise "new style should have different name" unless shogi.name == :Shogi
  raise "new style should have same side" unless shogi.side == style.side

  # Test with_side
  black_chess = style.with_side(:second)
  raise "with_side should return new instance" if black_chess.equal?(style)
  raise "new style should have different side" unless black_chess.side == :second
  raise "new style should have same name" unless black_chess.name == style.name
end

run_test("Style immutability") do
  style = Sashite::Snn::Style.new(:Chess, :first)

  # Test that style is frozen
  raise "style should be frozen" unless style.frozen?

  # Test that mutations don't affect original
  original_string = style.to_s
  flipped = style.flip

  raise "original style should be unchanged after flip" unless style.to_s == original_string
  raise "flipped style should be different" unless flipped.to_s == "chess"
end

run_test("Style equality and hash") do
  style1 = Sashite::Snn::Style.new(:Chess, :first)
  style2 = Sashite::Snn::Style.new(:Chess, :first)
  style3 = Sashite::Snn::Style.new(:Chess, :second)
  style4 = Sashite::Snn::Style.new(:Shogi, :first)

  # Test equality
  raise "identical styles should be equal" unless style1 == style2
  raise "different side should not be equal" if style1 == style3
  raise "different name should not be equal" if style1 == style4

  # Test hash consistency
  raise "equal styles should have same hash" unless style1.hash == style2.hash

  # Test in hash/set
  styles_set = Set.new([style1, style2, style3, style4])
  raise "set should contain 3 unique styles" unless styles_set.size == 3
end

run_test("Style name and side identification") do
  test_cases = [
    ["CHESS", :Chess, :first, true, false],
    ["chess", :Chess, :second, false, true],
    ["SHOGI", :Shogi, :first, true, false],
    ["shogi", :Shogi, :second, false, true]
  ]

  test_cases.each do |snn_string, expected_name, expected_side, is_first, is_second|
    style = Sashite::Snn.parse(snn_string)

    raise "#{snn_string}: wrong name" unless style.name == expected_name
    raise "#{snn_string}: wrong side" unless style.side == expected_side
    raise "#{snn_string}: wrong first_player?" unless style.first_player? == is_first
    raise "#{snn_string}: wrong second_player?" unless style.second_player? == is_second
  end
end

run_test("Style same_name? and same_side? methods") do
  chess1 = Sashite::Snn::Style.new(:Chess, :first)
  chess2 = Sashite::Snn::Style.new(:Chess, :second)
  shogi1 = Sashite::Snn::Style.new(:Shogi, :first)
  shogi2 = Sashite::Snn::Style.new(:Shogi, :second)

  # same_name? tests
  raise "Chess and Chess should be same name" unless chess1.same_name?(chess2)
  raise "Chess and Shogi should not be same name" if chess1.same_name?(shogi1)

  # same_side? tests
  raise "first player styles should be same side" unless chess1.same_side?(shogi1)
  raise "different side styles should not be same side" if chess1.same_side?(chess2)
end

run_test("Style transformation methods return self when appropriate") do
  style = Sashite::Snn::Style.new(:Chess, :first)

  # Test with_* methods that should return self
  raise "with_name with same name should return self" unless style.with_name(:Chess).equal?(style)
  raise "with_side with same side should return self" unless style.with_side(:first).equal?(style)
end

run_test("Style transformation chains") do
  style = Sashite::Snn::Style.new(:Chess, :first)

  # Test flip then flip
  flipped = style.flip
  back_to_original = flipped.flip
  raise "flip then flip should equal original" unless back_to_original == style

  # Test complex chain
  transformed = style.flip.with_name(:Shogi).flip
  raise "complex chain should work" unless transformed.to_s == "SHOGI"
  raise "original should be unchanged" unless style.to_s == "CHESS"
end

run_test("Style error handling for invalid symbols") do
  # Invalid names
  invalid_names = [nil, "", "chess", "CHESS", 1, []]

  invalid_names.each do |name|
    begin
      Sashite::Snn::Style.new(name, :first)
      raise "Should have raised error for invalid name #{name.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid name" unless e.message.include?("Name must be")
    end
  end

  # Invalid sides
  invalid_sides = [:invalid, :player1, :white, "first", 1, nil]

  invalid_sides.each do |side|
    begin
      Sashite::Snn::Style.new(:Chess, side)
      raise "Should have raised error for invalid side #{side.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid side" unless e.message.include?("Side must be")
    end
  end
end

run_test("Style error handling for invalid SNN strings") do
  # Invalid SNN strings
  invalid_snns = ["", "Chess", "123", nil, Object]

  invalid_snns.each do |snn|
    begin
      Sashite::Snn.parse(snn)
      raise "Should have raised error for #{snn.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid SNN" unless e.message.include?("Invalid SNN")
    end
  end
end

# Test game-specific examples with new API
run_test("Chess styles with new API") do
  # Standard chess
  chess = Sashite::Snn.style(:Chess, :first)
  raise "Chess should be first player" unless chess.first_player?
  raise "Chess name should be :Chess" unless chess.name == :Chess

  # Chess variants
  chess960 = Sashite::Snn.style(:Chess960, :first)
  raise "Chess960 name should be :Chess960" unless chess960.name == :Chess960
  raise "Chess960 SNN should be CHESS960" unless chess960.to_s == "CHESS960"

  koth = Sashite::Snn.style(:Koth, :first)
  raise "KOTH name should be :Koth" unless koth.name == :Koth
  raise "KOTH SNN should be KOTH" unless koth.to_s == "KOTH"
end

run_test("Shōgi styles with new API") do
  # Standard shōgi
  shogi = Sashite::Snn.style(:Shogi, :first)
  raise "Shogi should be first player" unless shogi.first_player?
  raise "Shogi name should be :Shogi" unless shogi.name == :Shogi
  raise "Shogi SNN should be SHOGI" unless shogi.to_s == "SHOGI"

  # Shōgi variants
  mini_shogi = Sashite::Snn.style(:Minishogi, :first)
  raise "Minishogi name should be :Minishogi" unless mini_shogi.name == :Minishogi
  raise "Minishogi SNN should be MINISHOGI" unless mini_shogi.to_s == "MINISHOGI"

  chu_shogi = Sashite::Snn.style(:Chushogi, :first)
  raise "Chushogi name should be :Chushogi" unless chu_shogi.name == :Chushogi
  raise "Chushogi SNN should be CHUSHOGI" unless chu_shogi.to_s == "CHUSHOGI"
end

run_test("Cross-game style transformations with new API") do
  # Test that styles can be transformed across different contexts
  style = Sashite::Snn.style(:Chess, :first)

  # Chain transformations
  transformed = style.flip.with_name(:Shogi).flip.with_name(:Xiangqi)
  expected_final = "XIANGQI"  # Should end up as first player Xiangqi

  raise "Chained transformation should work" unless transformed.to_s == expected_final
  raise "Original style should be unchanged" unless style.to_s == "CHESS"
end

# Test practical usage scenarios with new API
run_test("Practical usage - style collections with new API") do
  styles = [
    Sashite::Snn.style(:Chess, :first),
    Sashite::Snn.style(:Shogi, :first),
    Sashite::Snn.style(:Chess960, :first),
    Sashite::Snn.style(:Chess, :second)
  ]

  # Filter by side
  first_player_styles = styles.select(&:first_player?)
  raise "Should have 3 first player styles" unless first_player_styles.size == 3

  # Group by name
  by_name = styles.group_by(&:name)
  raise "Should have chess styles grouped" unless by_name[:Chess].size == 2

  # Find specific styles
  chess_styles = styles.select { |s| s.name == :Chess }
  raise "Should have 2 chess styles" unless chess_styles.size == 2
end

run_test("Practical usage - game configuration with new API") do
  # Simulate multi-style match setup
  white_style = Sashite::Snn.style(:Chess, :first)
  black_style = Sashite::Snn.style(:Shogi, :second)

  raise "White should be first player" unless white_style.first_player?
  raise "Black should be second player" unless black_style.second_player?
  raise "Styles should have different names" unless white_style.name != black_style.name
  raise "Styles should have different sides" unless !white_style.same_side?(black_style)

  # Test style switching
  switched = white_style.with_name(black_style.name)
  raise "Switched style should have black's name" unless switched.name == black_style.name
  raise "Switched style should keep white's side" unless switched.side == white_style.side
end

# Test edge cases
run_test("Edge case - alphanumeric identifiers with new API") do
  alphanumeric_styles = [
    [:Chess960, "CHESS960", "chess960"],
    [:A1, "A1", "a1"],
    [:Game123, "GAME123", "game123"],
    [:Style1, "STYLE1", "style1"]
  ]

  alphanumeric_styles.each do |name_symbol, first_display, second_display|
    # Test first player
    style1 = Sashite::Snn.style(name_symbol, :first)
    raise "#{name_symbol} should create valid style" unless style1.name == name_symbol
    raise "#{name_symbol} should be first player" unless style1.first_player?
    raise "#{name_symbol} should display as #{first_display}" unless style1.to_s == first_display

    # Test second player
    style2 = Sashite::Snn.style(name_symbol, :second)
    raise "#{name_symbol} should create valid style" unless style2.name == name_symbol
    raise "#{name_symbol} should be second player" unless style2.second_player?
    raise "#{name_symbol} should display as #{second_display}" unless style2.to_s == second_display

    # Test transformations
    flipped = style1.flip
    raise "#{name_symbol} flip should work" unless flipped.second_player?
    raise "#{name_symbol} flip should have correct display" unless flipped.to_s == second_display
  end
end

run_test("Edge case - name normalization from various input cases") do
  test_cases = [
    ["CHESS", :Chess],
    ["chess", :Chess],
    ["CHESS960", :Chess960],
    ["chess960", :Chess960],
    ["SHOGI", :Shogi],
    ["shogi", :Shogi],
    ["KOTH", :Koth],
    ["koth", :Koth]
  ]

  test_cases.each do |input, expected_name|
    style = Sashite::Snn.parse(input)
    raise "#{input} should normalize to #{expected_name}" unless style.name == expected_name
  end
end

run_test("Edge case - unicode and special characters still invalid") do
  unicode_chars = ["α", "β", "♕", "♔", "🀄", "象", "將", "CHESS-960", "CHESS_960"]

  unicode_chars.each do |char|
    raise "#{char.inspect} should be invalid (not alphanumeric)" if Sashite::Snn.valid?(char)
  end
end

run_test("Edge case - whitespace handling still works") do
  whitespace_cases = [
    " CHESS", "CHESS ", " chess", "chess ",
    "\tCHESS", "CHESS\t", "\nchess", "chess\n", " CHESS ", "\tchess\t"
  ]

  whitespace_cases.each do |snn|
    raise "#{snn.inspect} should be invalid (whitespace)" if Sashite::Snn.valid?(snn)
  end
end

run_test("Edge case - mixed case still invalid") do
  mixed_cases = ["Chess", "ChEsS", "chESs", "CheSs", "CHESS960chess", "ChessShogi"]

  mixed_cases.each do |snn|
    raise "#{snn.inspect} should be invalid (mixed case)" if Sashite::Snn.valid?(snn)
  end
end

# Test regex compliance
run_test("Regex pattern compliance") do
  # Test against the specification regex: \A([A-Z][A-Z0-9]*|[a-z][a-z0-9]*)\z
  spec_regex = /\A([A-Z][A-Z0-9]*|[a-z][a-z0-9]*)\z/

  test_strings = [
    "CHESS", "chess", "CHESS960", "chess960", "A", "a", "Z1", "z1",
    "", "Chess", "123", "1CHESS", "CHESS-960", "CHESS_960", "CHESS SHOGI"
  ]

  test_strings.each do |string|
    spec_match = string.match?(spec_regex)
    snn_valid = Sashite::Snn.valid?(string)

    raise "#{string.inspect}: spec regex and SNN validation disagree" unless spec_match == snn_valid
  end
end

# Test constants
run_test("SNN_REGEX constant is correctly defined") do
  regex = Sashite::Snn::SNN_REGEX

  raise "SNN_REGEX should match valid SNNs" unless "CHESS".match?(regex)
  raise "SNN_REGEX should match lowercase SNNs" unless "chess".match?(regex)
  raise "SNN_REGEX should not match mixed case" if "Chess".match?(regex)
end

# Test performance with new API
run_test("Performance - repeated operations with new API") do
  # Test performance with many repeated calls
  1000.times do
    style = Sashite::Snn.style(:Chess, :first)
    flipped = style.flip
    renamed = style.with_name(:Shogi)

    raise "Performance test failed" unless Sashite::Snn.valid?("CHESS")
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless renamed.name == :Shogi
  end
end

# Test constants and validation
run_test("Style class constants are properly defined") do
  style_class = Sashite::Snn::Style

  # Test side constants
  raise "FIRST_PLAYER should be :first" unless style_class::FIRST_PLAYER == :first
  raise "SECOND_PLAYER should be :second" unless style_class::SECOND_PLAYER == :second

  # Test valid sides
  raise "VALID_SIDES should contain correct values" unless style_class::VALID_SIDES == [:first, :second]
end

# Test roundtrip parsing
run_test("Roundtrip parsing consistency") do
  test_cases = [
    [:Chess, :first],
    [:Shogi, :second],
    [:Chess960, :first],
    [:Xiangqi, :second]
  ]

  test_cases.each do |name, side|
    # Create style -> to_s -> parse -> compare
    original = Sashite::Snn::Style.new(name, side)
    snn_string = original.to_s
    parsed = Sashite::Snn.parse(snn_string)

    raise "Roundtrip failed: original != parsed" unless original == parsed
    raise "Roundtrip failed: different name" unless original.name == parsed.name
    raise "Roundtrip failed: different side" unless original.side == parsed.side
  end
end

# Test name capitalization normalization
run_test("Name capitalization normalization") do
  test_cases = [
    # Input cases that should all normalize to the same symbol
    [["CHESS", "chess"], :Chess],
    [["SHOGI", "shogi"], :Shogi],
    [["CHESS960", "chess960"], :Chess960],
    [["XIANGQI", "xiangqi"], :Xiangqi],
    [["KOTH", "koth"], :Koth],
    [["A1B2C3", "a1b2c3"], :A1b2c3]
  ]

  test_cases.each do |inputs, expected_name|
    parsed_styles = inputs.map { |input| Sashite::Snn.parse(input) }

    # All should have the same normalized name
    parsed_styles.each do |style|
      raise "#{inputs.inspect} should normalize to #{expected_name}, got #{style.name}" unless style.name == expected_name
    end

    # But different sides
    raise "First input should be first player" unless parsed_styles[0].first_player?
    raise "Second input should be second player" unless parsed_styles[1].second_player?
  end
end

puts
puts "All SNN tests passed!"
puts
