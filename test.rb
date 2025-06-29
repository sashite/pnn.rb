# frozen_string_literal: true

# Tests for Sashite::Pnn (Piece Name Notation)
#
# Tests the PNN implementation for Ruby, focusing on the style-aware piece notation
# with derivation markers and cross-style game support.

require_relative "lib/sashite-pnn"
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
puts "Tests for Sashite::Pnn (Piece Name Notation)"
puts

# Test basic validation (module level)
run_test("Module PNN validation accepts valid notations") do
  valid_pnns = [
    # Basic PIN compatibility
    "K", "k", "Q", "q", "R", "r", "B", "b", "N", "n", "P", "p",
    "A", "a", "Z", "z",
    "+K", "+k", "+Q", "+q", "+R", "+r", "+B", "+b", "+N", "+n", "+P", "+p",
    "-K", "-k", "-Q", "-q", "-R", "-r", "-B", "-b", "-N", "-n", "-P", "-p",
    # PNN with foreign style markers
    "K'", "k'", "Q'", "q'", "R'", "r'", "B'", "b'", "N'", "n'", "P'", "p'",
    "A'", "a'", "Z'", "z'",
    "+K'", "+k'", "+Q'", "+q'", "+R'", "+r'", "+B'", "+b'", "+N'", "+n'", "+P'", "+p'",
    "-K'", "-k'", "-Q'", "-q'", "-R'", "-r'", "-B'", "-b'", "-N'", "-n'", "-P'", "-p'"
  ]

  valid_pnns.each do |pnn|
    raise "#{pnn.inspect} should be valid" unless Sashite::Pnn.valid?(pnn)
  end
end

run_test("Module PNN validation rejects invalid notations") do
  invalid_pnns = [
    # Basic invalid cases
    "", "KK", "++K", "--K", "+-K", "-+K", "K+", "K-", "+", "-",
    "1", "9", "0", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
    " K", "K ", " +K", "+K ", "k+", "k-", "Kk", "kK",
    "123", "ABC", "abc", "K1", "1K", "+1", "-1", "1+", "1-",
    # PNN-specific invalid cases
    "K''", "k''", "+'K", "'-K", "K'+", "K'-", "'K", "'k",
    "++K'", "--K'", "K+'", "K-'", " K'", "K' ", "K 'K",
    "K'K", "K'Q", "+K''", "-K''"
  ]

  invalid_pnns.each do |pnn|
    raise "#{pnn.inspect} should be invalid" if Sashite::Pnn.valid?(pnn)
  end
end

run_test("Module PNN validation handles non-string input") do
  non_strings = [nil, 123, :king, [], {}, true, false, 1.5]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Pnn.valid?(input)
  end
end

# Test module parse method delegates to Piece
run_test("Module parse delegates to Piece class") do
  pnn_string = "+R'"
  piece = Sashite::Pnn.parse(pnn_string)

  raise "parse should return PNN Piece instance" unless piece.is_a?(Sashite::Pnn::Piece)
  raise "piece should have correct PNN string" unless piece.to_s == pnn_string
end

# Test PIN compatibility
run_test("PNN maintains PIN compatibility") do
  pin_strings = ["K", "k", "+R", "-p", "Q", "B"]

  pin_strings.each do |pin|
    # Should be valid in both PIN and PNN
    raise "#{pin} should be valid PIN" unless Sashite::Pin.valid?(pin)
    raise "#{pin} should be valid PNN" unless Sashite::Pnn.valid?(pin)

    # Should parse correctly in both
    pin_piece = Sashite::Pin.parse(pin)
    pnn_piece = Sashite::Pnn.parse(pin)

    raise "PIN and PNN should parse to same letter" unless pin_piece.letter == pnn_piece.letter
    raise "PIN and PNN should parse to same state" unless pin_piece.enhanced? == pnn_piece.enhanced?
    raise "PIN and PNN should parse to same state" unless pin_piece.diminished? == pnn_piece.diminished?
  end
end

# Test the Piece class
run_test("Piece.parse creates correct instances") do
  test_cases = {
    "K" => { letter: "K", enhanced: false, diminished: false, native: true },
    "k'" => { letter: "k", enhanced: false, diminished: false, native: false },
    "+R" => { letter: "R", enhanced: true, diminished: false, native: true },
    "+R'" => { letter: "R", enhanced: true, diminished: false, native: false },
    "-p" => { letter: "p", enhanced: false, diminished: true, native: true },
    "-p'" => { letter: "p", enhanced: false, diminished: true, native: false }
  }

  test_cases.each do |pnn_string, expected|
    piece = Sashite::Pnn.parse(pnn_string)

    raise "#{pnn_string}: wrong letter" unless piece.letter == expected[:letter]
    raise "#{pnn_string}: wrong enhanced state" unless piece.enhanced? == expected[:enhanced]
    raise "#{pnn_string}: wrong diminished state" unless piece.diminished? == expected[:diminished]
    raise "#{pnn_string}: wrong native state" unless piece.native? == expected[:native]
  end
end

run_test("Piece to_s returns correct PNN string") do
  test_cases = [
    ["K", true, false, false, "K"],
    ["k", false, false, false, "k'"],
    ["R", true, true, false, "+R"],
    ["R", false, true, false, "+R'"],
    ["p", true, false, true, "-p"],
    ["p", false, false, true, "-p'"]
  ]

  test_cases.each do |letter, native, enhanced, diminished, expected|
    piece = Sashite::Pnn::Piece.new(letter, native: native, enhanced: enhanced, diminished: diminished)
    result = piece.to_s

    raise "#{letter} with native=#{native}, enhanced=#{enhanced}, diminished=#{diminished} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Piece to_pin returns PIN representation") do
  test_cases = [
    ["K", true, false, false, "K"],
    ["k'", false, false, false, "k"],
    ["+R", true, true, false, "+R"],
    ["+R'", false, true, false, "+R"],
    ["-p", true, false, true, "-p"],
    ["-p'", false, false, true, "-p"]
  ]

  test_cases.each do |pnn_string, native, enhanced, diminished, expected_pin|
    piece = Sashite::Pnn.parse(pnn_string)
    pin_result = piece.to_pin

    raise "#{pnn_string} should convert to PIN #{expected_pin}, got #{pin_result}" unless pin_result == expected_pin
  end
end

run_test("Piece style queries") do
  native_piece = Sashite::Pnn.parse("K")
  foreign_piece = Sashite::Pnn.parse("K'")

  # Native piece tests
  raise "native piece should be native" unless native_piece.native?
  raise "native piece should not be foreign" if native_piece.foreign?

  # Foreign piece tests
  raise "foreign piece should not be native" if foreign_piece.native?
  raise "foreign piece should be foreign" unless foreign_piece.foreign?
end

run_test("Piece style mutations return new instances") do
  piece = Sashite::Pnn.parse("K")

  # Test nativize on native piece (should return self)
  nativized = piece.nativize
  raise "nativize on native piece should return self" unless nativized.equal?(piece)

  # Test foreignize
  foreignized = piece.foreignize
  raise "foreignize should return new instance" if foreignized.equal?(piece)
  raise "foreignized piece should be foreign" unless foreignized.foreign?
  raise "original piece should be unchanged" unless piece.native?
  raise "foreignized piece should have same letter" unless foreignized.letter == piece.letter

  # Test round-trip
  back_to_native = foreignized.nativize
  raise "back to native should equal original" unless back_to_native == piece

  # Test toggle_style
  toggled = piece.toggle_style
  raise "toggle should return new instance" if toggled.equal?(piece)
  raise "toggled piece should be foreign" unless toggled.foreign?

  toggled_back = toggled.toggle_style
  raise "toggle back should equal original" unless toggled_back == piece
end

run_test("Piece state mutations preserve style") do
  foreign_piece = Sashite::Pnn.parse("K'")

  # Test enhance preserves style
  enhanced = foreign_piece.enhance
  raise "enhanced piece should be foreign" unless enhanced.foreign?
  raise "enhanced piece should be enhanced" unless enhanced.enhanced?
  raise "enhanced piece PIN should be +K'" unless enhanced.to_s == "+K'"

  # Test diminish preserves style
  diminished = foreign_piece.diminish
  raise "diminished piece should be foreign" unless diminished.foreign?
  raise "diminished piece should be diminished" unless diminished.diminished?
  raise "diminished piece PIN should be -K'" unless diminished.to_s == "-K'"

  # Test flip preserves style
  flipped = foreign_piece.flip
  raise "flipped piece should be foreign" unless flipped.foreign?
  raise "flipped piece should have lowercase letter" unless flipped.letter == "k"
  raise "flipped piece PIN should be k'" unless flipped.to_s == "k'"
end

run_test("Piece constructor validation") do
  # Valid constructor calls
  valid_cases = [
    ["K", { native: true }],
    ["k", { native: false }],
    ["R", { native: true, enhanced: true }],
    ["p", { native: false, enhanced: false, diminished: true }]
  ]

  valid_cases.each do |letter, opts|
    piece = Sashite::Pnn::Piece.new(letter, **opts)
    raise "Should create valid piece for #{letter} with #{opts}" unless piece.is_a?(Sashite::Pnn::Piece)
  end

  # Invalid native parameter
  invalid_native_cases = [nil, "true", 1, 0, :true, [true]]

  invalid_native_cases.each do |invalid_native|
    begin
      Sashite::Pnn::Piece.new("K", native: invalid_native)
      raise "Should have raised error for native=#{invalid_native.inspect}"
    rescue ArgumentError => e
      raise "Error should mention native parameter" unless e.message.include?("Native must be")
    end
  end
end

run_test("Piece immutability") do
  piece = Sashite::Pnn.parse("+R'")

  # Test that piece is frozen
  raise "piece should be frozen" unless piece.frozen?

  # Test that letter is frozen
  raise "letter should be frozen" unless piece.letter.frozen?

  # Test that mutations don't affect original
  original_string = piece.to_s
  normalized = piece.normalize
  nativized = piece.nativize

  raise "original piece should be unchanged after normalize" unless piece.to_s == original_string
  raise "original piece should be unchanged after nativize" unless piece.to_s == original_string
  raise "normalized piece should be different" unless normalized.to_s == "R'"
  raise "nativized piece should be different" unless nativized.to_s == "+R"
end

run_test("Piece equality and hash including style") do
  piece1 = Sashite::Pnn.parse("K")
  piece2 = Sashite::Pnn.parse("K")
  piece3 = Sashite::Pnn.parse("K'")
  piece4 = Sashite::Pnn.parse("k")
  piece5 = Sashite::Pnn.parse("+K")

  # Test equality
  raise "identical pieces should be equal" unless piece1 == piece2
  raise "different style should not be equal" if piece1 == piece3
  raise "different case should not be equal" if piece1 == piece4
  raise "different state should not be equal" if piece1 == piece5

  # Test hash consistency
  raise "equal pieces should have same hash" unless piece1.hash == piece2.hash

  # Test in hash/set
  pieces_set = Set.new([piece1, piece2, piece3, piece4, piece5])
  raise "set should contain 4 unique pieces" unless pieces_set.size == 4
end

run_test("Piece inherits PIN functionality") do
  piece = Sashite::Pnn.parse("K'")

  # Test inherited queries
  raise "should inherit type method" unless piece.type == "K"
  raise "should inherit side method" unless piece.side == :first
  raise "should inherit first_player? method" unless piece.first_player?
  raise "should not be second_player" if piece.second_player?

  # Test inherited comparison methods
  other_king = Sashite::Pnn.parse("k'")
  queen = Sashite::Pnn.parse("Q'")

  raise "should recognize same type" unless piece.same_type?(other_king)
  raise "should recognize different type" if piece.same_type?(queen)
  raise "should recognize different player" if piece.same_player?(other_king)
  raise "should recognize same player" unless piece.same_player?(queen)
end

run_test("Cross-style game scenarios") do
  # Chess vs Shōgi scenario
  # First player: Chess (native), Shōgi (foreign)
  # Second player: Shōgi (native), Chess (foreign)

  chess_pawn_white = Sashite::Pnn.parse("P")      # Native Chess pawn for first player
  shogi_pawn_white = Sashite::Pnn.parse("P'")     # Foreign Shōgi pawn for first player
  shogi_pawn_black = Sashite::Pnn.parse("p")      # Native Shōgi pawn for second player
  chess_pawn_black = Sashite::Pnn.parse("p'")     # Foreign Chess pawn for second player

  # Verify styles
  raise "White Chess pawn should be native" unless chess_pawn_white.native?
  raise "White Shōgi pawn should be foreign" unless shogi_pawn_white.foreign?
  raise "Black Shōgi pawn should be native" unless shogi_pawn_black.native?
  raise "Black Chess pawn should be foreign" unless chess_pawn_black.foreign?

  # Test promotions preserving style
  promoted_shogi = shogi_pawn_white.enhance
  raise "Promoted Shōgi pawn should be +P'" unless promoted_shogi.to_s == "+P'"
  raise "Promoted Shōgi pawn should remain foreign" unless promoted_shogi.foreign?
end

run_test("Style conversions during gameplay") do
  # Simulate capture and style conversion
  enemy_piece = Sashite::Pnn.parse("p'")          # Enemy's foreign piece
  captured = enemy_piece.flip.nativize            # Convert to our side with native style
  raise "Captured piece should be P" unless captured.to_s == "P"
  raise "Captured piece should be native" unless captured.native?
  raise "Captured piece should be first player" unless captured.first_player?

  # Simulate promotion with style preservation
  foreign_pawn = Sashite::Pnn.parse("p'")         # Foreign pawn
  promoted = foreign_pawn.enhance                 # Promote while keeping foreign style
  raise "Promoted foreign pawn should be +p'" unless promoted.to_s == "+p'"
  raise "Promoted piece should remain foreign" unless promoted.foreign?
end

# Test error handling
run_test("Piece error handling") do
  # Invalid PNN strings
  invalid_pnns = ["", "KK", "++K", "K''", "123", nil, "'K", "K'K"]

  invalid_pnns.each do |pnn|
    begin
      Sashite::Pnn.parse(pnn)
      raise "Should have raised error for #{pnn.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid PNN" unless e.message.include?("Invalid PNN")
    end
  end

  # Invalid constructor arguments (inherited from PIN)
  begin
    Sashite::Pnn::Piece.new("KK")
    raise "Should have raised error for invalid letter"
  rescue ArgumentError => e
    raise "Error message should mention invalid letter" unless e.message.include?("Letter must be")
  end

  begin
    Sashite::Pnn::Piece.new("K", enhanced: true, diminished: true)
    raise "Should have raised error for conflicting states"
  rescue ArgumentError => e
    raise "Error message should mention conflicting states" unless e.message.include?("both enhanced and diminished")
  end
end

# Test game-specific examples
run_test("Western Chess pieces with PNN") do
  # Standard pieces (native style assumed)
  king = Sashite::Pnn.parse("K")
  raise "King should be native" unless king.native?
  raise "King should be first player" unless king.first_player?

  # Foreign Chess pieces in hybrid game
  foreign_king = Sashite::Pnn.parse("K'")
  raise "Foreign king should be foreign" unless foreign_king.foreign?
  raise "Foreign king PIN should be K'" unless foreign_king.to_s == "K'"

  # State modifiers with styles
  castling_king = king.enhance
  raise "Castling king should be +K" unless castling_king.to_s == "+K"

  foreign_castling_king = foreign_king.enhance
  raise "Foreign castling king should be +K'" unless foreign_castling_king.to_s == "+K'"
end

run_test("Japanese Chess (Shōgi) pieces with PNN") do
  # Basic pieces
  rook = Sashite::Pnn.parse("R")
  foreign_rook = Sashite::Pnn.parse("R'")

  # Promoted pieces
  dragon_king = rook.enhance
  raise "Dragon King should be +R" unless dragon_king.to_s == "+R"
  raise "Dragon King should be native" unless dragon_king.native?

  foreign_dragon_king = foreign_rook.enhance
  raise "Foreign Dragon King should be +R'" unless foreign_dragon_king.to_s == "+R'"
  raise "Foreign Dragon King should be foreign" unless foreign_dragon_king.foreign?
end

run_test("Cross-game piece transformations") do
  # Test that pieces can be transformed across different styles
  piece = Sashite::Pnn.parse("K")

  # Chain transformations including style changes
  transformed = piece.flip.enhance.foreignize.flip.diminish.nativize
  expected_final = "-K"  # Should end up as diminished first player king with native style

  raise "Chained transformation should work" unless transformed.to_s == expected_final
  raise "Original piece should be unchanged" unless piece.to_s == "K"
  raise "Final piece should be native" unless transformed.native?
end

# Test practical usage scenarios
run_test("Practical usage - mixed style collections") do
  pieces = [
    Sashite::Pnn.parse("K"),      # Native white king
    Sashite::Pnn.parse("Q'"),     # Foreign white queen
    Sashite::Pnn.parse("+R"),     # Native enhanced white rook
    Sashite::Pnn.parse("+R'"),    # Foreign enhanced white rook
    Sashite::Pnn.parse("k"),      # Native black king
    Sashite::Pnn.parse("k'")      # Foreign black king
  ]

  # Filter by style
  native_pieces = pieces.select(&:native?)
  foreign_pieces = pieces.select(&:foreign?)
  raise "Should have 3 native pieces" unless native_pieces.size == 3
  raise "Should have 3 foreign pieces" unless foreign_pieces.size == 3

  # Filter by player and style
  white_native = pieces.select { |p| p.first_player? && p.native? }
  raise "Should have 2 white native pieces" unless white_native.size == 2

  # Group by type regardless of style
  by_type = pieces.group_by(&:type)
  raise "Should have 3 kings" unless by_type["K"].size == 3  # K, k, k'
  raise "Should have 1 queen" unless by_type["Q"].size == 1  # Q'
  raise "Should have 2 rooks" unless by_type["R"].size == 2  # +R, +R'
end

run_test("Practical usage - style conversion simulation") do
  # Simulate dropping captured pieces in Shōgi-style
  captured_enemy = Sashite::Pnn.parse("p'")  # Foreign enemy pawn

  # Convert to our piece with our style
  our_piece = captured_enemy.flip.nativize
  raise "Converted piece should be P" unless our_piece.to_s == "P"
  raise "Converted piece should be our player" unless our_piece.first_player?
  raise "Converted piece should be native style" unless our_piece.native?

  # Place it back as enhanced
  placed_enhanced = our_piece.enhance
  raise "Placed enhanced should be +P" unless placed_enhanced.to_s == "+P"
end

# Test edge cases
run_test("Edge case - all letters with foreign style") do
  letters = ("A".."Z").to_a + ("a".."z").to_a

  letters.each do |letter|
    # Test with foreign style marker
    foreign = "#{letter}'"
    raise "#{foreign} should be valid" unless Sashite::Pnn.valid?(foreign)

    piece = Sashite::Pnn.parse(foreign)
    raise "#{foreign} should parse as foreign" unless piece.foreign?
    raise "#{foreign} should have correct letter" unless piece.letter == letter

    # Test with enhanced state and foreign style
    enhanced_foreign = "+#{letter}'"
    raise "#{enhanced_foreign} should be valid" unless Sashite::Pnn.valid?(enhanced_foreign)

    enhanced_piece = Sashite::Pnn.parse(enhanced_foreign)
    raise "#{enhanced_foreign} should be enhanced and foreign" unless enhanced_piece.enhanced? && enhanced_piece.foreign?

    # Test with diminished state and foreign style
    diminished_foreign = "-#{letter}'"
    raise "#{diminished_foreign} should be valid" unless Sashite::Pnn.valid?(diminished_foreign)

    diminished_piece = Sashite::Pnn.parse(diminished_foreign)
    raise "#{diminished_foreign} should be diminished and foreign" unless diminished_piece.diminished? && diminished_piece.foreign?
  end
end

run_test("Edge case - invalid foreign style markers") do
  invalid_foreign = [
    "K''", "k''", "++K'", "--K'", "K'K", "K'Q", "'K", "'k",
    "K 'K", "K' ", " K'", "+'K", "'-K", "K'+"
  ]

  invalid_foreign.each do |pnn|
    raise "#{pnn.inspect} should be invalid" if Sashite::Pnn.valid?(pnn)
  end
end

run_test("Edge case - foreign style with all state combinations") do
  base_letters = ["K", "k", "R", "r"]

  base_letters.each do |letter|
    # Normal foreign
    normal_foreign = "#{letter}'"
    piece = Sashite::Pnn.parse(normal_foreign)
    raise "#{normal_foreign} should be normal and foreign" unless piece.normal? && piece.foreign?

    # Enhanced foreign
    enhanced_foreign = "+#{letter}'"
    piece = Sashite::Pnn.parse(enhanced_foreign)
    raise "#{enhanced_foreign} should be enhanced and foreign" unless piece.enhanced? && piece.foreign?

    # Diminished foreign
    diminished_foreign = "-#{letter}'"
    piece = Sashite::Pnn.parse(diminished_foreign)
    raise "#{diminished_foreign} should be diminished and foreign" unless piece.diminished? && piece.foreign?
  end
end

# Test regex compliance
run_test("Regex pattern compliance") do
  # Test against the PNN specification regex: \A[-+]?[A-Za-z]'?\z
  spec_regex = /\A[-+]?[A-Za-z]'?\z/

  test_strings = [
    "K", "k", "+K", "+k", "-K", "-k", "K'", "k'", "+K'", "+k'", "-K'", "-k'",
    "A", "z", "+A", "-z", "A'", "z'", "+A'", "-z'",
    "", "KK", "++K", "--K", "K+", "K-", "+", "-", "1", "!", "K''", "'K"
  ]

  test_strings.each do |string|
    spec_match = string.match?(spec_regex)
    pnn_valid = Sashite::Pnn.valid?(string)

    raise "#{string.inspect}: spec regex and PNN validation disagree" unless spec_match == pnn_valid
  end
end

# Test inheritance chain
run_test("Inheritance from PIN::Piece") do
  piece = Sashite::Pnn.parse("K'")

  # Should be instance of both classes
  raise "Should be instance of Pnn::Piece" unless piece.is_a?(Sashite::Pnn::Piece)
  raise "Should be instance of Pin::Piece" unless piece.is_a?(Sashite::Pin::Piece)

  # Should respond to all PIN methods
  pin_methods = [:letter, :enhance, :diminish, :flip, :type, :side, :first_player?, :second_player?,
                 :enhanced?, :diminished?, :normal?, :same_type?, :same_player?, :state]

  pin_methods.each do |method|
    raise "Should respond to #{method}" unless piece.respond_to?(method)
  end

  # Should respond to PNN-specific methods
  pnn_methods = [:native?, :foreign?, :nativize, :foreignize, :toggle_style, :to_pin]

  pnn_methods.each do |method|
    raise "Should respond to #{method}" unless piece.respond_to?(method)
  end
end

# Test performance
run_test("Performance - repeated operations with styles") do
  # Test performance with many repeated calls including style operations
  1000.times do
    piece = Sashite::Pnn.parse("K'")
    enhanced = piece.enhance
    flipped = piece.flip
    foreignized = piece.foreignize
    nativized = piece.nativize

    raise "Performance test failed" unless Sashite::Pnn.valid?("K'")
    raise "Performance test failed" unless enhanced.enhanced?
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless foreignized.foreign?
    raise "Performance test failed" unless nativized.native?
  end
end

run_test("Performance - complex style chains") do
  # Test performance with complex transformation chains
  100.times do
    piece = Sashite::Pnn.parse("K")
    result = piece.enhance.foreignize.flip.diminish.nativize.toggle_style.normalize

    raise "Complex chain should work" unless result.is_a?(Sashite::Pnn::Piece)
    raise "Original should be unchanged" unless piece.to_s == "K"
  end
end

# Test comprehensive style scenarios
run_test("Comprehensive style scenario - hybrid game") do
  # Simulate a Chess vs Shōgi match with piece captures and promotions

  # Initial setup: Chess player (first) vs Shōgi player (second)
  chess_pieces = [
    Sashite::Pnn.parse("K"),    # White king (Chess native)
    Sashite::Pnn.parse("Q"),    # White queen (Chess native)
    Sashite::Pnn.parse("P")     # White pawn (Chess native)
  ]

  shogi_pieces = [
    Sashite::Pnn.parse("k"),    # Black king (Shōgi native)
    Sashite::Pnn.parse("g"),    # Black gold (Shōgi native)
    Sashite::Pnn.parse("p")     # Black pawn (Shōgi native)
  ]

  # Chess player captures Shōgi pieces (adopts Shōgi style)
  captured_gold = shogi_pieces[1].flip.foreignize  # G' (foreign gold for Chess player)
  raise "Captured gold should be G'" unless captured_gold.to_s == "G'"
  raise "Captured gold should be foreign to Chess player" unless captured_gold.foreign?

  # Shōgi player captures Chess pieces (adopts Chess style)
  captured_queen = chess_pieces[1].flip.foreignize  # q' (foreign queen for Shōgi player)
  raise "Captured queen should be q'" unless captured_queen.to_s == "q'"
  raise "Captured queen should be foreign to Shōgi player" unless captured_queen.foreign?

  # Promotions preserving styles
  promoted_chess_pawn = chess_pieces[2].enhance    # +P (Chess promotion)
  promoted_shogi_pawn = shogi_pieces[2].enhance    # +p (Shōgi promotion)

  raise "Chess promoted pawn should be +P" unless promoted_chess_pawn.to_s == "+P"
  raise "Shōgi promoted pawn should be +p" unless promoted_shogi_pawn.to_s == "+p"
  raise "Both should remain native to their respective players" unless promoted_chess_pawn.native? && promoted_shogi_pawn.native?
end

# Test edge case: empty and whitespace strings
run_test("Edge case - empty and whitespace PNN strings") do
  empty_cases = ["", " ", "\t", "\n", "\r", "  ", "\t\n"]

  empty_cases.each do |empty|
    raise "#{empty.inspect} should be invalid" if Sashite::Pnn.valid?(empty)

    begin
      Sashite::Pnn.parse(empty)
      raise "Should have raised error for #{empty.inspect}"
    rescue ArgumentError
      # Expected
    end
  end
end

# Test case sensitivity of foreign marker
run_test("Foreign marker case sensitivity") do
  # Only lowercase apostrophe should be valid
  valid_foreign = ["K'", "k'", "+R'", "-p'"]

  valid_foreign.each do |pnn|
    raise "#{pnn} should be valid" unless Sashite::Pnn.valid?(pnn)
    piece = Sashite::Pnn.parse(pnn)
    raise "#{pnn} should parse as foreign" unless piece.foreign?
  end

  # Test that other quote characters are invalid
  invalid_quotes = ["K\"", "K`", "K´", "K^", "K‛"]

  invalid_quotes.each do |pnn|
    raise "#{pnn} should be invalid (wrong quote)" if Sashite::Pnn.valid?(pnn)
  end
end

# Test memory efficiency and object reuse
run_test("Memory efficiency - object identity for noop operations") do
  piece = Sashite::Pnn.parse("K")

  # Operations that should return self
  same_operations = [
    piece.nativize,      # Already native
    piece.unenhance,     # Already normal
    piece.undiminish,    # Already normal
    piece.normalize      # Already normal
  ]

  same_operations.each do |result|
    raise "Noop operation should return same object" unless result.equal?(piece)
  end

  # Operations that should return new objects
  different_operations = [
    piece.foreignize,
    piece.enhance,
    piece.diminish,
    piece.flip,
    piece.toggle_style
  ]

  different_operations.each do |result|
    raise "Mutation operation should return new object" if result.equal?(piece)
  end
end

# Test string interpolation and conversion
run_test("String interpolation and conversion") do
  piece = Sashite::Pnn.parse("+K'")

  # Test string interpolation
  interpolated = "Piece: #{piece}"
  raise "String interpolation should work" unless interpolated == "Piece: +K'"

  # Test explicit string conversion
  explicit = piece.to_s
  raise "Explicit to_s should work" unless explicit == "+K'"

  # Test that to_s and interpolation are consistent
  raise "to_s and interpolation should be consistent" unless "#{piece}" == piece.to_s
end

# Test thread safety (immutability verification)
run_test("Thread safety through immutability") do
  piece = Sashite::Pnn.parse("K")

  # Simulate concurrent access
  results = []
  threads = []

  10.times do |i|
    threads << Thread.new do
      # Perform various operations
      enhanced = piece.enhance
      foreign = piece.foreignize
      flipped = piece.flip

      results << [enhanced.to_s, foreign.to_s, flipped.to_s]
    end
  end

  threads.each(&:join)

  # All results should be identical (proving immutability)
  expected = ["+K", "K'", "k"]
  results.each do |result|
    raise "Thread safety violated" unless result == expected
  end

  # Original piece should be unchanged
  raise "Original piece should be unchanged" unless piece.to_s == "K"
end

# Test collection behavior
run_test("Collection behavior with mixed styles") do
  pieces = [
    Sashite::Pnn.parse("K"),   # Native
    Sashite::Pnn.parse("K'"),  # Foreign
    Sashite::Pnn.parse("k"),   # Native
    Sashite::Pnn.parse("k'")   # Foreign
  ]

  # Test uniqueness in sets
  unique_pieces = Set.new(pieces)
  raise "All pieces should be unique" unless unique_pieces.size == 4

  # Test sorting (should work via to_s)
  sorted = pieces.sort_by(&:to_s)
  expected_order = ["K", "K'", "k", "k'"]
  actual_order = sorted.map(&:to_s)
  raise "Sorting should work" unless actual_order == expected_order

  # Test grouping by style
  by_style = pieces.group_by(&:native?)
  raise "Should have 2 native pieces" unless by_style[true].size == 2
  raise "Should have 2 foreign pieces" unless by_style[false].size == 2
end

# Test integration with PIN ecosystem
run_test("Integration with PIN ecosystem") do
  # Create PIN piece
  pin_piece = Sashite::Pin.parse("+R")

  # Create equivalent PNN piece
  pnn_piece = Sashite::Pnn.parse("+R")

  # Test compatibility
  raise "PIN and PNN should have same letter" unless pin_piece.letter == pnn_piece.letter
  raise "PIN and PNN should have same enhanced state" unless pin_piece.enhanced? == pnn_piece.enhanced?
  raise "PIN and PNN should have same type" unless pin_piece.type == pnn_piece.type
  raise "PIN and PNN should have same side" unless pin_piece.side == pnn_piece.side

  # Test that PNN to_pin matches PIN to_s
  raise "PNN to_pin should match PIN to_s" unless pnn_piece.to_pin == pin_piece.to_s

  # Test that both work with same PIN methods
  pin_flipped = pin_piece.flip
  pnn_flipped = pnn_piece.flip

  raise "Both should flip to same letter" unless pin_flipped.letter == pnn_flipped.letter
end

# Test complex real-world scenarios
run_test("Real-world scenario - complete game simulation") do
  # Simulate a complex game with captures, promotions, and style changes

  # Initial pieces
  white_pawn = Sashite::Pnn.parse("P'")     # Foreign (Shōgi) pawn
  black_pawn = Sashite::Pnn.parse("p'")     # Foreign (Chess) pawn

  # Game progression
  # 1. Promote pawns
  white_promoted = white_pawn.enhance       # +P' (promoted foreign pawn)
  black_promoted = black_pawn.enhance       # +p' (promoted foreign pawn)

  # 2. Capture and convert
  captured_white = white_promoted.flip.nativize  # +p (captured, converted to native)
  captured_black = black_promoted.flip.nativize  # +P (captured, converted to native)

  # 3. Verify final states
  raise "White promoted should be +P'" unless white_promoted.to_s == "+P'"
  raise "Black promoted should be +p'" unless black_promoted.to_s == "+p'"
  raise "Captured white should be +p" unless captured_white.to_s == "+p"
  raise "Captured black should be +P" unless captured_black.to_s == "+P"

  # 4. Verify style consistency
  raise "Captured pieces should be native" unless captured_white.native? && captured_black.native?
  raise "Original promoted should remain foreign" unless white_promoted.foreign? && black_promoted.foreign?

  # 5. Verify state preservation through style changes
  raise "Enhanced state should be preserved" unless captured_white.enhanced? && captured_black.enhanced?
end

# Test edge case with maximum complexity
run_test("Maximum complexity piece transformations") do
  # Start with a complex piece
  piece = Sashite::Pnn.parse("-k'")  # Diminished foreign black king

  # Apply maximum transformations
  result = piece
    .undiminish    # k'
    .enhance       # +k'
    .flip          # +K'
    .nativize      # +K
    .diminish      # -K (enhanced -> diminished)
    .foreignize    # -K'
    .flip          # -k'
    .normalize     # k'
    .toggle_style  # k

  expected = "k"
  raise "Complex transformation should result in #{expected}" unless result.to_s == expected
  raise "Result should be native" unless result.native?
  raise "Result should be normal" unless result.normal?
  raise "Result should be second player" unless result.second_player?

  # Original should be unchanged
  raise "Original should be unchanged" unless piece.to_s == "-k'"
end

puts
puts "All PNN tests passed!"
puts
