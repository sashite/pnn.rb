# frozen_string_literal: true

# Tests for Sashite::Pnn (Piece Name Notation)
#
# Tests the PNN implementation for Ruby, focusing on the modern object-oriented API
# with the Piece class using symbol-based attributes and style derivation support.

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
    # Native pieces (PIN compatible)
    "K", "k", "Q", "q", "R", "r", "B", "b", "N", "n", "P", "p",
    "A", "a", "Z", "z",
    "+K", "+k", "+Q", "+q", "+R", "+r", "+B", "+b", "+N", "+n", "+P", "+p",
    "-K", "-k", "-Q", "-q", "-R", "-r", "-B", "-b", "-N", "-n", "-P", "-p",
    # Foreign pieces (with derivation suffix)
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
    # Basic invalid patterns
    "", "KK", "++K", "--K", "+-K", "-+K", "K+", "K-", "+", "-",
    "1", "9", "0", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",
    " K", "K ", " +K", "+K ", "k+", "k-", "Kk", "kK",
    "123", "ABC", "abc", "K1", "1K", "+1", "-1", "1+", "1-",
    # PNN-specific invalid patterns
    "'", "K''", "K'+", "+カ'", "+'K", "''K", "K'K", "'K'",
    " K'", "K' ", " +K'", "+K' ", "++K'", "--K'", "K'+"
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

  raise "parse should return Piece instance" unless piece.is_a?(Sashite::Pnn::Piece)
  raise "piece should have correct PNN string" unless piece.to_s == pnn_string
end

# Test module piece factory method
run_test("Module piece factory method creates correct instances") do
  piece = Sashite::Pnn.piece(:K, :first, :enhanced, false)

  raise "piece factory should return Piece instance" unless piece.is_a?(Sashite::Pnn::Piece)
  raise "piece should have correct type" unless piece.type == :K
  raise "piece should have correct side" unless piece.side == :first
  raise "piece should have correct state" unless piece.state == :enhanced
  raise "piece should have correct derivation" unless piece.native == false
  raise "piece should have correct PNN string" unless piece.to_s == "+K'"
end

# Test the Piece class with PNN-specific features
run_test("Piece.parse creates correct instances with all attributes") do
  test_cases = {
    "K" => { type: :K, side: :first, state: :normal, native: true, letter: "K", suffix: "" },
    "k" => { type: :K, side: :second, state: :normal, native: true, letter: "k", suffix: "" },
    "+R" => { type: :R, side: :first, state: :enhanced, native: true, letter: "R", suffix: "" },
    "-p" => { type: :P, side: :second, state: :diminished, native: true, letter: "p", suffix: "" },
    "K'" => { type: :K, side: :first, state: :normal, native: false, letter: "K", suffix: "'" },
    "k'" => { type: :K, side: :second, state: :normal, native: false, letter: "k", suffix: "'" },
    "+R'" => { type: :R, side: :first, state: :enhanced, native: false, letter: "R", suffix: "'" },
    "-p'" => { type: :P, side: :second, state: :diminished, native: false, letter: "p", suffix: "'" }
  }

  test_cases.each do |pnn_string, expected|
    piece = Sashite::Pnn.parse(pnn_string)

    raise "#{pnn_string}: wrong type" unless piece.type == expected[:type]
    raise "#{pnn_string}: wrong side" unless piece.side == expected[:side]
    raise "#{pnn_string}: wrong state" unless piece.state == expected[:state]
    raise "#{pnn_string}: wrong native" unless piece.native == expected[:native]
    raise "#{pnn_string}: wrong letter" unless piece.letter == expected[:letter]
    raise "#{pnn_string}: wrong suffix" unless piece.suffix == expected[:suffix]
  end
end

run_test("Piece constructor with all parameters") do
  test_cases = [
    [:K, :first, :normal, true, "K"],
    [:K, :second, :normal, true, "k"],
    [:R, :first, :enhanced, true, "+R"],
    [:P, :second, :diminished, true, "-p"],
    [:K, :first, :normal, false, "K'"],
    [:K, :second, :normal, false, "k'"],
    [:R, :first, :enhanced, false, "+R'"],
    [:P, :second, :diminished, false, "-p'"]
  ]

  test_cases.each do |type, side, state, native, expected_pnn|
    piece = Sashite::Pnn::Piece.new(type, side, state, native)

    raise "type should be #{type}" unless piece.type == type
    raise "side should be #{side}" unless piece.side == side
    raise "state should be #{state}" unless piece.state == state
    raise "native should be #{native}" unless piece.native == native
    raise "PNN string should be #{expected_pnn}" unless piece.to_s == expected_pnn
  end
end

run_test("Piece to_s returns correct PNN string") do
  test_cases = [
    [:K, :first, :normal, true, "K"],
    [:K, :second, :normal, true, "k"],
    [:R, :first, :enhanced, true, "+R"],
    [:P, :second, :diminished, true, "-p"],
    [:K, :first, :normal, false, "K'"],
    [:K, :second, :normal, false, "k'"],
    [:R, :first, :enhanced, false, "+R'"],
    [:P, :second, :diminished, false, "-p'"]
  ]

  test_cases.each do |type, side, state, native, expected|
    piece = Sashite::Pnn::Piece.new(type, side, state, native)
    result = piece.to_s

    raise "#{type}, #{side}, #{state}, #{native} should be #{expected}, got #{result}" unless result == expected
  end
end

run_test("Piece letter, prefix, and suffix methods") do
  test_cases = [
    ["K", "K", "", ""],
    ["k", "k", "", ""],
    ["+R", "R", "+", ""],
    ["-p", "p", "-", ""],
    ["K'", "K", "", "'"],
    ["k'", "k", "", "'"],
    ["+R'", "R", "+", "'"],
    ["-p'", "p", "-", "'"]
  ]

  test_cases.each do |pnn_string, expected_letter, expected_prefix, expected_suffix|
    piece = Sashite::Pnn.parse(pnn_string)

    raise "#{pnn_string}: wrong letter" unless piece.letter == expected_letter
    raise "#{pnn_string}: wrong prefix" unless piece.prefix == expected_prefix
    raise "#{pnn_string}: wrong suffix" unless piece.suffix == expected_suffix
    raise "#{pnn_string}: to_s should equal prefix + letter + suffix" unless piece.to_s == "#{piece.prefix}#{piece.letter}#{piece.suffix}"
  end
end

run_test("Piece state mutations return new instances") do
  piece = Sashite::Pnn::Piece.new(:K, :first, :normal, true)

  # Test enhance
  enhanced = piece.enhance
  raise "enhance should return new instance" if enhanced.equal?(piece)
  raise "enhanced piece should be enhanced" unless enhanced.enhanced?
  raise "enhanced piece state should be :enhanced" unless enhanced.state == :enhanced
  raise "enhanced piece should preserve derivation" unless enhanced.native == piece.native
  raise "original piece should be unchanged" unless piece.state == :normal

  # Test diminish
  diminished = piece.diminish
  raise "diminish should return new instance" if diminished.equal?(piece)
  raise "diminished piece should be diminished" unless diminished.diminished?
  raise "diminished piece state should be :diminished" unless diminished.state == :diminished
  raise "diminished piece should preserve derivation" unless diminished.native == piece.native
  raise "original piece should be unchanged" unless piece.state == :normal

  # Test flip
  flipped = piece.flip
  raise "flip should return new instance" if flipped.equal?(piece)
  raise "flipped piece should have opposite side" unless flipped.side == :second
  raise "flipped piece should preserve type, state, and derivation" unless flipped.type == piece.type && flipped.state == piece.state && flipped.native == piece.native
  raise "original piece should be unchanged" unless piece.side == :first
end

run_test("Piece style mutations return new instances") do
  piece = Sashite::Pnn::Piece.new(:K, :first, :normal, true)

  # Test derive
  derived = piece.derive
  raise "derive should return new instance" if derived.equal?(piece)
  raise "derived piece should be foreign" unless derived.derived?
  raise "derived piece native should be false" unless derived.native == false
  raise "derived piece should preserve type, side, and state" unless derived.type == piece.type && derived.side == piece.side && derived.state == piece.state
  raise "original piece should be unchanged" unless piece.native == true

  # Test underive
  foreign_piece = Sashite::Pnn::Piece.new(:Q, :second, :enhanced, false)
  underived = foreign_piece.underive
  raise "underive should return new instance" if underived.equal?(foreign_piece)
  raise "underived piece should be native" unless underived.native?
  raise "underived piece native should be true" unless underived.native == true
  raise "underived piece should preserve type, side, and state" unless underived.type == foreign_piece.type && underived.side == foreign_piece.side && underived.state == foreign_piece.state
  raise "original piece should be unchanged" unless foreign_piece.native == false
end

run_test("Piece attribute transformations") do
  piece = Sashite::Pnn::Piece.new(:K, :first, :normal, true)

  # Test with_type
  queen = piece.with_type(:Q)
  raise "with_type should return new instance" if queen.equal?(piece)
  raise "new piece should have different type" unless queen.type == :Q
  raise "new piece should have same side, state, and derivation" unless queen.side == piece.side && queen.state == piece.state && queen.native == piece.native

  # Test with_side
  black_king = piece.with_side(:second)
  raise "with_side should return new instance" if black_king.equal?(piece)
  raise "new piece should have different side" unless black_king.side == :second
  raise "new piece should have same type, state, and derivation" unless black_king.type == piece.type && black_king.state == piece.state && black_king.native == piece.native

  # Test with_state
  enhanced_king = piece.with_state(:enhanced)
  raise "with_state should return new instance" if enhanced_king.equal?(piece)
  raise "new piece should have different state" unless enhanced_king.state == :enhanced
  raise "new piece should have same type, side, and derivation" unless enhanced_king.type == piece.type && enhanced_king.side == piece.side && enhanced_king.native == piece.native

  # Test with_derivation
  foreign_king = piece.with_derivation(false)
  raise "with_derivation should return new instance" if foreign_king.equal?(piece)
  raise "new piece should have different derivation" unless foreign_king.native == false
  raise "new piece should have same type, side, and state" unless foreign_king.type == piece.type && foreign_king.side == piece.side && foreign_king.state == piece.state
end

run_test("Piece immutability") do
  piece = Sashite::Pnn::Piece.new(:R, :first, :enhanced, false)

  # Test that piece is frozen
  raise "piece should be frozen" unless piece.frozen?

  # Test that mutations don't affect original
  original_string = piece.to_s
  normalized = piece.normalize
  derived = piece.underive

  raise "original piece should be unchanged after normalize" unless piece.to_s == original_string
  raise "normalized piece should be different" unless normalized.to_s == "R'"
  raise "underived piece should be different" unless derived.to_s == "+R"
end

run_test("Piece equality and hash") do
  piece1 = Sashite::Pnn::Piece.new(:K, :first, :normal, true)
  piece2 = Sashite::Pnn::Piece.new(:K, :first, :normal, true)
  piece3 = Sashite::Pnn::Piece.new(:K, :second, :normal, true)
  piece4 = Sashite::Pnn::Piece.new(:K, :first, :enhanced, true)
  piece5 = Sashite::Pnn::Piece.new(:K, :first, :normal, false)

  # Test equality
  raise "identical pieces should be equal" unless piece1 == piece2
  raise "different side should not be equal" if piece1 == piece3
  raise "different state should not be equal" if piece1 == piece4
  raise "different derivation should not be equal" if piece1 == piece5

  # Test hash consistency
  raise "equal pieces should have same hash" unless piece1.hash == piece2.hash

  # Test in hash/set
  pieces_set = Set.new([piece1, piece2, piece3, piece4, piece5])
  raise "set should contain 4 unique pieces" unless pieces_set.size == 4
end

run_test("Piece type and side identification") do
  test_cases = [
    ["K", :K, :first, true, false],
    ["k", :K, :second, false, true],
    ["+R'", :R, :first, true, false],
    ["-p'", :P, :second, false, true]
  ]

  test_cases.each do |pnn_string, expected_type, expected_side, is_first, is_second|
    piece = Sashite::Pnn.parse(pnn_string)

    raise "#{pnn_string}: wrong type" unless piece.type == expected_type
    raise "#{pnn_string}: wrong side" unless piece.side == expected_side
    raise "#{pnn_string}: wrong first_player?" unless piece.first_player? == is_first
    raise "#{pnn_string}: wrong second_player?" unless piece.second_player? == is_second
  end
end

run_test("Piece same_type?, same_side?, same_state?, and same_style? methods") do
  king1 = Sashite::Pnn::Piece.new(:K, :first, :normal, true)
  king2 = Sashite::Pnn::Piece.new(:K, :second, :enhanced, false)
  queen = Sashite::Pnn::Piece.new(:Q, :first, :normal, true)
  foreign_queen = Sashite::Pnn::Piece.new(:Q, :second, :enhanced, false)

  # same_type? tests
  raise "K and K should be same type" unless king1.same_type?(king2)
  raise "K and Q should not be same type" if king1.same_type?(queen)

  # same_side? tests
  raise "first player pieces should be same side" unless king1.same_side?(queen)
  raise "different side pieces should not be same side" if king1.same_side?(king2)

  # same_state? tests
  raise "normal pieces should be same state" unless king1.same_state?(queen)
  raise "enhanced pieces should be same state" unless king2.same_state?(foreign_queen)
  raise "different state pieces should not be same state" if king1.same_state?(king2)

  # same_style? tests
  raise "native pieces should be same style" unless king1.same_style?(queen)
  raise "foreign pieces should be same style" unless king2.same_style?(foreign_queen)
  raise "different style pieces should not be same style" if king1.same_style?(king2)
end

run_test("Piece state and style methods") do
  normal_native = Sashite::Pnn::Piece.new(:K, :first, :normal, true)
  enhanced_foreign = Sashite::Pnn::Piece.new(:K, :first, :enhanced, false)
  diminished_native = Sashite::Pnn::Piece.new(:K, :first, :diminished, true)

  # Test state identification
  raise "normal piece should be normal" unless normal_native.normal?
  raise "normal piece should not be enhanced" if normal_native.enhanced?
  raise "normal piece should not be diminished" if normal_native.diminished?
  raise "normal piece state should be :normal" unless normal_native.state == :normal

  raise "enhanced piece should be enhanced" unless enhanced_foreign.enhanced?
  raise "enhanced piece should not be normal" if enhanced_foreign.normal?
  raise "enhanced piece state should be :enhanced" unless enhanced_foreign.state == :enhanced

  raise "diminished piece should be diminished" unless diminished_native.diminished?
  raise "diminished piece should not be normal" if diminished_native.normal?
  raise "diminished piece state should be :diminished" unless diminished_native.state == :diminished

  # Test style identification
  raise "native piece should be native" unless normal_native.native?
  raise "native piece should not be derived" if normal_native.derived?
  raise "native piece should not be foreign" if normal_native.foreign?

  raise "foreign piece should be derived" unless enhanced_foreign.derived?
  raise "foreign piece should be foreign" unless enhanced_foreign.foreign?
  raise "foreign piece should not be native" if enhanced_foreign.native?
end

run_test("Piece transformation methods return self when appropriate") do
  normal_native = Sashite::Pnn::Piece.new(:K, :first, :normal, true)
  enhanced_foreign = Sashite::Pnn::Piece.new(:K, :first, :enhanced, false)
  diminished_native = Sashite::Pnn::Piece.new(:K, :first, :diminished, true)

  # Test state methods that should return self
  raise "unenhance on normal piece should return self" unless normal_native.unenhance.equal?(normal_native)
  raise "undiminish on normal piece should return self" unless normal_native.undiminish.equal?(normal_native)
  raise "normalize on normal piece should return self" unless normal_native.normalize.equal?(normal_native)
  raise "enhance on enhanced piece should return self" unless enhanced_foreign.enhance.equal?(enhanced_foreign)
  raise "diminish on diminished piece should return self" unless diminished_native.diminish.equal?(diminished_native)

  # Test style methods that should return self
  raise "underive on native piece should return self" unless normal_native.underive.equal?(normal_native)
  raise "derive on foreign piece should return self" unless enhanced_foreign.derive.equal?(enhanced_foreign)

  # Test with_* methods that should return self
  raise "with_type with same type should return self" unless normal_native.with_type(:K).equal?(normal_native)
  raise "with_side with same side should return self" unless normal_native.with_side(:first).equal?(normal_native)
  raise "with_state with same state should return self" unless normal_native.with_state(:normal).equal?(normal_native)
  raise "with_derivation with same derivation should return self" unless normal_native.with_derivation(true).equal?(normal_native)
end

run_test("Piece transformation chains") do
  piece = Sashite::Pnn::Piece.new(:K, :first, :normal, true)

  # Test enhance then unenhance
  enhanced = piece.enhance
  back_to_normal = enhanced.unenhance
  raise "enhance then unenhance should equal original" unless back_to_normal == piece

  # Test diminish then undiminish
  diminished = piece.diminish
  back_to_normal2 = diminished.undiminish
  raise "diminish then undiminish should equal original" unless back_to_normal2 == piece

  # Test derive then underive
  derived = piece.derive
  back_to_native = derived.underive
  raise "derive then underive should equal original" unless back_to_native == piece

  # Test complex chain
  transformed = piece.flip.derive.enhance.with_type(:Q).diminish
  raise "complex chain should work" unless transformed.to_s == "-q'"
  raise "original should be unchanged" unless piece.to_s == "K"
end

run_test("Piece error handling for invalid parameters") do
  # Invalid types
  invalid_types = [:invalid, :k, :"1", :AA, "K", 1, nil]

  invalid_types.each do |type|
    begin
      Sashite::Pnn::Piece.new(type, :first, :normal, true)
      raise "Should have raised error for invalid type #{type.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid type" unless e.message.include?("Type must be")
    end
  end

  # Invalid sides
  invalid_sides = [:invalid, :player1, :white, "first", 1, nil]

  invalid_sides.each do |side|
    begin
      Sashite::Pnn::Piece.new(:K, side, :normal, true)
      raise "Should have raised error for invalid side #{side.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid side" unless e.message.include?("Side must be")
    end
  end

  # Invalid states
  invalid_states = [:invalid, :promoted, :active, "normal", 1, nil]

  invalid_states.each do |state|
    begin
      Sashite::Pnn::Piece.new(:K, :first, state, true)
      raise "Should have raised error for invalid state #{state.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid state" unless e.message.include?("State must be")
    end
  end

  # Invalid derivations
  invalid_derivations = [:invalid, "true", "false", 1, 0, nil, "native"]

  invalid_derivations.each do |derivation|
    begin
      Sashite::Pnn::Piece.new(:K, :first, :normal, derivation)
      raise "Should have raised error for invalid derivation #{derivation.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid derivation" unless e.message.include?("Derivation must be")
    end
  end
end

run_test("Piece error handling for invalid PNN strings") do
  # Invalid PNN strings
  invalid_pnns = ["", "KK", "++K", "123", nil, :symbol, "'", "K''", "++K'"]

  invalid_pnns.each do |pnn|
    begin
      Sashite::Pnn.parse(pnn)
      raise "Should have raised error for #{pnn.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid PNN" unless e.message.include?("Invalid PNN")
    end
  end
end

# Test PIN compatibility
run_test("PIN compatibility - all PIN strings are valid PNN") do
  pin_strings = [
    "K", "k", "Q", "q", "R", "r", "B", "b", "N", "n", "P", "p",
    "A", "a", "Z", "z",
    "+K", "+k", "+Q", "+q", "+R", "+r", "+B", "+b", "+N", "+n", "+P", "+p",
    "-K", "-k", "-Q", "-q", "-R", "-r", "-B", "-b", "-N", "-n", "-P", "-p"
  ]

  pin_strings.each do |pin|
    # Should be valid as PNN
    raise "PIN string #{pin.inspect} should be valid PNN" unless Sashite::Pnn.valid?(pin)

    # Should parse correctly as native piece
    piece = Sashite::Pnn.parse(pin)
    raise "PIN string should parse as native piece" unless piece.native?

    # Should round-trip correctly
    raise "PIN string should round-trip" unless piece.to_s == pin
  end
end

# Test cross-style game examples
run_test("Cross-style Chess vs. Shōgi pieces") do
  # Native pieces (no derivation suffix)
  white_king = Sashite::Pnn.piece(:K, :first, :normal, true)          # Chess king
  black_king = Sashite::Pnn.piece(:K, :second, :normal, true)         # Shōgi king

  # Foreign pieces (with derivation suffix)
  white_shogi_king = Sashite::Pnn.piece(:K, :first, :normal, false)   # Shōgi king for white
  black_chess_king = Sashite::Pnn.piece(:K, :second, :normal, false)  # Chess king for black

  raise "White native king should be 'K'" unless white_king.to_s == "K"
  raise "Black native king should be 'k'" unless black_king.to_s == "k"
  raise "White foreign king should be 'K''" unless white_shogi_king.to_s == "K'"
  raise "Black foreign king should be 'k''" unless black_chess_king.to_s == "k'"

  # Promoted pieces in cross-style context
  white_promoted_rook = Sashite::Pnn.parse("+R'")  # White shōgi rook promoted to Dragon King
  black_promoted_pawn = Sashite::Pnn.parse("+p")   # Black shōgi pawn promoted to Tokin

  raise "White promoted rook should be enhanced" unless white_promoted_rook.enhanced?
  raise "White promoted rook should be foreign" unless white_promoted_rook.derived?
  raise "Black promoted pawn should be enhanced" unless black_promoted_pawn.enhanced?
  raise "Black promoted pawn should be native" unless black_promoted_pawn.native?
end

run_test("Style mutation during gameplay simulation") do
  # Simulate capture with style change (Ōgi rules)
  chess_queen = Sashite::Pnn.parse("q'")           # Black chess queen (foreign for shōgi player)
  captured = chess_queen.flip.with_type(:P).underive  # Becomes white native pawn

  raise "Original should be black foreign queen" unless chess_queen.to_s == "q'"
  raise "Captured should be white native pawn" unless captured.to_s == "P"

  # Style derivation changes during gameplay
  shogi_piece = Sashite::Pnn.parse("r")           # Black shōgi rook (native)
  foreign_piece = shogi_piece.derive              # Convert to foreign style

  raise "Original should be native" unless shogi_piece.native?
  raise "Converted should be foreign" unless foreign_piece.derived?
  raise "Foreign piece should be 'r''" unless foreign_piece.to_s == "r'"
end

# Test practical usage scenarios
run_test("Practical usage - piece collections with derivation") do
  pieces = [
    Sashite::Pnn.piece(:K, :first, :normal, true),    # Native white king
    Sashite::Pnn.piece(:Q, :first, :normal, false),   # Foreign white queen
    Sashite::Pnn.piece(:R, :first, :enhanced, true),  # Native white promoted rook
    Sashite::Pnn.piece(:K, :second, :normal, false),  # Foreign black king
    Sashite::Pnn.piece(:P, :second, :normal, true)    # Native black pawn
  ]

  # Filter by side
  first_player_pieces = pieces.select(&:first_player?)
  raise "Should have 3 first player pieces" unless first_player_pieces.size == 3

  # Group by style derivation
  native_pieces = pieces.select(&:native?)
  foreign_pieces = pieces.select(&:derived?)
  raise "Should have 3 native pieces" unless native_pieces.size == 3
  raise "Should have 2 foreign pieces" unless foreign_pieces.size == 2

  # Find promoted pieces
  promoted = pieces.select(&:enhanced?)
  raise "Should have 1 promoted piece" unless promoted.size == 1
  raise "Promoted piece should be rook" unless promoted.first.type == :R
end

run_test("Practical usage - game state simulation with style") do
  # Simulate promoting a pawn with style considerations
  native_pawn = Sashite::Pnn.piece(:P, :first, :normal, true)
  foreign_pawn = Sashite::Pnn.piece(:P, :first, :normal, false)

  raise "Native pawn should be normal initially" unless native_pawn.normal?
  raise "Foreign pawn should be normal initially" unless foreign_pawn.normal?

  # Promote to queen using with_type and enhance, preserving style
  native_promoted = native_pawn.with_type(:Q).enhance
  foreign_promoted = foreign_pawn.with_type(:Q).enhance

  raise "Native promoted piece should be queen" unless native_promoted.type == :Q
  raise "Native promoted piece should be enhanced" unless native_promoted.enhanced?
  raise "Native promoted piece should remain native" unless native_promoted.native?
  raise "Native promoted should be '+Q'" unless native_promoted.to_s == "+Q"

  raise "Foreign promoted piece should be queen" unless foreign_promoted.type == :Q
  raise "Foreign promoted piece should be enhanced" unless foreign_promoted.enhanced?
  raise "Foreign promoted piece should remain foreign" unless foreign_promoted.derived?
  raise "Foreign promoted should be '+Q''" unless foreign_promoted.to_s == "+Q'"

  # Simulate capturing and flipping with style preservation
  captured_native = native_promoted.flip  # Becomes enemy piece, keeps native style
  captured_foreign = foreign_promoted.flip  # Becomes enemy piece, keeps foreign style

  raise "Captured native should be second player" unless captured_native.second_player?
  raise "Captured native should still be enhanced" unless captured_native.enhanced?
  raise "Captured native should still be queen" unless captured_native.type == :Q
  raise "Captured native should remain native" unless captured_native.native?
  raise "Captured native should be '+q'" unless captured_native.to_s == "+q"

  raise "Captured foreign should be second player" unless captured_foreign.second_player?
  raise "Captured foreign should still be enhanced" unless captured_foreign.enhanced?
  raise "Captured foreign should still be queen" unless captured_foreign.type == :Q
  raise "Captured foreign should remain foreign" unless captured_foreign.derived?
  raise "Captured foreign should be '+q''" unless captured_foreign.to_s == "+q'"
end

# Test edge cases
run_test("Edge case - all letters of alphabet with derivation") do
  letters = ("A".."Z").to_a

  letters.each do |letter|
    type_symbol = letter.to_sym

    # Test first player native
    piece1 = Sashite::Pnn.piece(type_symbol, :first, :normal, true)
    raise "#{letter} should create valid native piece" unless piece1.type == type_symbol
    raise "#{letter} should be first player" unless piece1.first_player?
    raise "#{letter} should be native" unless piece1.native?
    raise "#{letter} should have correct letter" unless piece1.letter == letter
    raise "#{letter} should have correct PNN" unless piece1.to_s == letter

    # Test first player foreign
    piece2 = Sashite::Pnn.piece(type_symbol, :first, :normal, false)
    raise "#{letter} should create valid foreign piece" unless piece2.type == type_symbol
    raise "#{letter} should be first player" unless piece2.first_player?
    raise "#{letter} should be foreign" unless piece2.derived?
    raise "#{letter} should have correct letter" unless piece2.letter == letter
    raise "#{letter} should have correct PNN" unless piece2.to_s == "#{letter}'"

    # Test second player native
    piece3 = Sashite::Pnn.piece(type_symbol, :second, :normal, true)
    raise "#{letter} should create valid native piece" unless piece3.type == type_symbol
    raise "#{letter} should be second player" unless piece3.second_player?
    raise "#{letter} should be native" unless piece3.native?
    raise "#{letter} should have correct letter" unless piece3.letter == letter.downcase
    raise "#{letter} should have correct PNN" unless piece3.to_s == letter.downcase

    # Test second player foreign
    piece4 = Sashite::Pnn.piece(type_symbol, :second, :normal, false)
    raise "#{letter} should create valid foreign piece" unless piece4.type == type_symbol
    raise "#{letter} should be second player" unless piece4.second_player?
    raise "#{letter} should be foreign" unless piece4.derived?
    raise "#{letter} should have correct letter" unless piece4.letter == letter.downcase
    raise "#{letter} should have correct PNN" unless piece4.to_s == "#{letter.downcase}'"

    # Test enhanced native state
    enhanced = piece1.enhance
    raise "#{letter} enhanced should work" unless enhanced.enhanced?
    raise "#{letter} enhanced should have + prefix" unless enhanced.prefix == "+"
    raise "#{letter} enhanced should preserve style" unless enhanced.native?
    raise "#{letter} enhanced should have correct PNN" unless enhanced.to_s == "+#{letter}"

    # Test enhanced foreign state
    enhanced_foreign = piece2.enhance
    raise "#{letter} enhanced foreign should work" unless enhanced_foreign.enhanced?
    raise "#{letter} enhanced foreign should have + prefix" unless enhanced_foreign.prefix == "+"
    raise "#{letter} enhanced foreign should preserve style" unless enhanced_foreign.derived?
    raise "#{letter} enhanced foreign should have correct PNN" unless enhanced_foreign.to_s == "+#{letter}'"

    # Test diminished state
    diminished = piece1.diminish
    raise "#{letter} diminished should work" unless diminished.diminished?
    raise "#{letter} diminished should have - prefix" unless diminished.prefix == "-"
    raise "#{letter} diminished should preserve style" unless diminished.native?
    raise "#{letter} diminished should have correct PNN" unless diminished.to_s == "-#{letter}"
  end
end

run_test("Edge case - unicode and special characters still invalid") do
  unicode_chars = ["α", "β", "♕", "♔", "🀄", "象", "將"]

  unicode_chars.each do |char|
    raise "#{char.inspect} should be invalid (not ASCII)" if Sashite::Pnn.valid?(char)
    raise "#{char.inspect} with + should be invalid" if Sashite::Pnn.valid?("+#{char}")
    raise "#{char.inspect} with - should be invalid" if Sashite::Pnn.valid?("-#{char}")
    raise "#{char.inspect} with ' should be invalid" if Sashite::Pnn.valid?("#{char}'")
    raise "#{char.inspect} with +' should be invalid" if Sashite::Pnn.valid?("+#{char}'")
  end
end

run_test("Edge case - whitespace handling still works") do
  whitespace_cases = [
    " K", "K ", " +K", "+K ", " -K", "-K ",
    " K'", "K' ", " +K'", "+K' ", " -K'", "-K' ",
    "\tK", "K\t", "\n+K", "+K\n", " K ", "\t+K'\t"
  ]

  whitespace_cases.each do |pnn|
    raise "#{pnn.inspect} should be invalid (whitespace)" if Sashite::Pnn.valid?(pnn)
  end
end

run_test("Edge case - multiple suffixes and invalid combinations") do
  invalid_combinations = [
    "K''", "K'''", "+K''", "-K''", "++K'", "--K'", "+-K'", "-+K'",
    "'K", "K'+", "K'-", "'", "''", "'''", "K'K", "'K'"
  ]

  invalid_combinations.each do |pnn|
    raise "#{pnn.inspect} should be invalid (invalid combination)" if Sashite::Pnn.valid?(pnn)
  end
end

# Test validation behavior with edge cases specific to PNN
run_test("PNN validation edge cases") do
  # Empty derivation suffix cases
  edge_cases = [
    ["'", false],        # Just apostrophe
    ["", false],         # Empty string
    ["K''", false],      # Double apostrophe
    ["'K", false],       # Apostrophe before letter
    ["K'K", false],      # Letter after apostrophe
    ["K'+'", false],     # Invalid characters after apostrophe
    ["+", false],        # Just plus
    ["-", false],        # Just minus
    ["+'", false],       # Plus with apostrophe but no letter
    ["-'", false]        # Minus with apostrophe but no letter
  ]

  edge_cases.each do |pnn_string, should_be_valid|
    result = Sashite::Pnn.valid?(pnn_string)
    if should_be_valid
      raise "#{pnn_string.inspect} should be valid" unless result
    else
      raise "#{pnn_string.inspect} should be invalid" if result
    end
  end
end

# Test performance with PNN extensions
run_test("Performance - repeated operations with PNN features") do
  # Test performance with many repeated calls including derivation
  1000.times do
    piece = Sashite::Pnn.piece(:K, :first, :normal, true)
    enhanced = piece.enhance
    derived = piece.derive
    flipped = piece.flip
    queen = piece.with_type(:Q)
    foreign_enhanced = piece.derive.enhance

    raise "Performance test failed" unless Sashite::Pnn.valid?("K")
    raise "Performance test failed" unless Sashite::Pnn.valid?("K'")
    raise "Performance test failed" unless enhanced.enhanced?
    raise "Performance test failed" unless derived.derived?
    raise "Performance test failed" unless flipped.second_player?
    raise "Performance test failed" unless queen.type == :Q
    raise "Performance test failed" unless foreign_enhanced.to_s == "+K'"
  end
end

# Test constants validation
run_test("PNN class constants are properly defined") do
  piece_class = Sashite::Pnn::Piece

  # Test derivation constants
  raise "NATIVE should be true" unless piece_class::NATIVE == true
  raise "FOREIGN should be false" unless piece_class::FOREIGN == false

  # Test suffix constants
  raise "FOREIGN_SUFFIX should be \"'\"" unless piece_class::FOREIGN_SUFFIX == "'"
  raise "NATIVE_SUFFIX should be \"\"" unless piece_class::NATIVE_SUFFIX == ""

  # Test validation arrays
  raise "VALID_DERIVATIONS should include both values" unless piece_class::VALID_DERIVATIONS.include?(true) && piece_class::VALID_DERIVATIONS.include?(false)
end

# Test roundtrip parsing consistency with derivation
run_test("Roundtrip parsing consistency including derivation") do
  test_cases = [
    [:K, :first, :normal, true],
    [:Q, :second, :enhanced, false],
    [:P, :first, :diminished, true],
    [:Z, :second, :normal, false],
    [:A, :first, :enhanced, false],
    [:B, :second, :diminished, true]
  ]

  test_cases.each do |type, side, state, native|
    # Create piece -> to_s -> parse -> compare
    original = Sashite::Pnn::Piece.new(type, side, state, native)
    pnn_string = original.to_s
    parsed = Sashite::Pnn.parse(pnn_string)

    raise "Roundtrip failed: original != parsed" unless original == parsed
    raise "Roundtrip failed: different type" unless original.type == parsed.type
    raise "Roundtrip failed: different side" unless original.side == parsed.side
    raise "Roundtrip failed: different state" unless original.state == parsed.state
    raise "Roundtrip failed: different derivation" unless original.native == parsed.native
  end
end

# Test delegation to PIN piece for core functionality
run_test("PIN delegation works correctly") do
  pnn_piece = Sashite::Pnn.piece(:K, :first, :enhanced, false)

  # Test that PIN-related methods work correctly
  raise "Type should work via delegation" unless pnn_piece.type == :K
  raise "Side should work via delegation" unless pnn_piece.side == :first
  raise "State should work via delegation" unless pnn_piece.state == :enhanced
  raise "Enhanced? should work via delegation" unless pnn_piece.enhanced?
  raise "First player? should work via delegation" unless pnn_piece.first_player?
  raise "Letter should work via delegation" unless pnn_piece.letter == "K"
  raise "Prefix should work via delegation" unless pnn_piece.prefix == "+"

  # Test that PNN-specific attributes work
  raise "Native should be PNN-specific" unless pnn_piece.native == false
  raise "Derived? should work" unless pnn_piece.derived?
  raise "Suffix should be PNN-specific" unless pnn_piece.suffix == "'"
end

# Test conversion between PIN and PNN
run_test("PIN to PNN conversion and compatibility") do
  # Test that PIN pieces can be represented in PNN as native pieces
  pin_examples = ["K", "+R", "-p", "q"]

  pin_examples.each do |pin_string|
    # Parse as PNN (should work since PIN is subset of PNN)
    pnn_piece = Sashite::Pnn.parse(pin_string)

    # Should be native style
    raise "PIN piece should parse as native in PNN" unless pnn_piece.native?

    # Should round-trip back to same string
    raise "PIN->PNN should round-trip" unless pnn_piece.to_s == pin_string

    # Should match PIN validation
    raise "PNN should validate same as PIN for PIN strings" unless Sashite::Pnn.valid?(pin_string)
  end
end

# Test error handling for edge cases
run_test("Error handling for PNN-specific edge cases") do
  # Test that apostrophe-only strings fail gracefully
  apostrophe_cases = ["'", "''", "'''", "'K", "K'K", "+'", "-'"]

  apostrophe_cases.each do |case_string|
    raise "#{case_string.inspect} should be invalid" if Sashite::Pnn.valid?(case_string)

    begin
      Sashite::Pnn.parse(case_string)
      raise "#{case_string.inspect} should raise ArgumentError"
    rescue ArgumentError => e
      raise "Error should mention invalid PNN" unless e.message.include?("Invalid PNN")
    end
  end
end

puts
puts "All PNN tests passed!"
puts
