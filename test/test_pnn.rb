# frozen_string_literal: true

require "simplecov"
SimpleCov.start

# Tests for Pnn module and Pnn::Piece class
#
# This test suite covers the complete PNN (Piece Name Notation) implementation
# including both the modern object-oriented API (Pnn::Piece) and the legacy
# hash-based API for backward compatibility.
#
# Tests cover:
# - PNN string parsing and validation
# - Piece state manipulation (enhanced, diminished, intermediate)
# - Ownership changes (case flipping)
# - Legacy API compatibility
# - Error handling and edge cases
# - Object equality and hashing
# - String representation and inspection

require_relative "../lib/pnn"

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
puts "Tests for Pnn module and Pnn::Piece class"
puts

# ============================================================================
# Basic Parsing Tests
# ============================================================================

run_test("Parse simple piece - lowercase") do
  piece = Pnn::Piece.parse("k")

  raise "Wrong letter" unless piece.letter == "k"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should be lowercase" unless piece.lowercase?
  raise "Should not be uppercase" if piece.uppercase?
  raise "Should be bare" unless piece.bare?
end

run_test("Parse simple piece - uppercase") do
  piece = Pnn::Piece.parse("K")

  raise "Wrong letter" unless piece.letter == "K"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should be uppercase" unless piece.uppercase?
  raise "Should not be lowercase" if piece.lowercase?
  raise "Should be bare" unless piece.bare?
end

run_test("Parse enhanced piece") do
  piece = Pnn::Piece.parse("+k")

  raise "Wrong letter" unless piece.letter == "k"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse diminished piece") do
  piece = Pnn::Piece.parse("-K")

  raise "Wrong letter" unless piece.letter == "K"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should be diminished" unless piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse intermediate piece") do
  piece = Pnn::Piece.parse("p'")

  raise "Wrong letter" unless piece.letter == "p"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse complex piece - enhanced and intermediate") do
  piece = Pnn::Piece.parse("+q'")

  raise "Wrong letter" unless piece.letter == "q"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse complex piece - diminished and intermediate") do
  piece = Pnn::Piece.parse("-R'")

  raise "Wrong letter" unless piece.letter == "R"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should be diminished" unless piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

# ============================================================================
# Constructor Tests
# ============================================================================

run_test("Create simple piece with new constructor") do
  piece = Pnn::Piece.new("k")

  raise "Wrong letter" unless piece.letter == "k"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should be bare" unless piece.bare?
  raise "Should be lowercase" unless piece.lowercase?
  raise "Should not be uppercase" if piece.uppercase?
end

run_test("Create enhanced piece with new constructor") do
  piece = Pnn::Piece.new("K", enhanced: true)

  raise "Wrong letter" unless piece.letter == "K"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
  raise "Should be uppercase" unless piece.uppercase?
  raise "Should not be lowercase" if piece.lowercase?
end

run_test("Create complex piece with new constructor") do
  piece = Pnn::Piece.new("p", enhanced: true, intermediate: true)

  raise "Wrong letter" unless piece.letter == "p"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

# ============================================================================
# String Conversion Tests
# ============================================================================

run_test("Convert simple piece to string") do
  piece = Pnn::Piece.parse("k")

  raise "Wrong string representation" unless piece.to_s == "k"
end

run_test("Convert enhanced piece to string") do
  piece = Pnn::Piece.parse("+k")

  raise "Wrong string representation" unless piece.to_s == "+k"
end

run_test("Convert diminished piece to string") do
  piece = Pnn::Piece.parse("-K")

  raise "Wrong string representation" unless piece.to_s == "-K"
end

run_test("Convert intermediate piece to string") do
  piece = Pnn::Piece.parse("p'")

  raise "Wrong string representation" unless piece.to_s == "p'"
end

run_test("Convert complex piece to string") do
  piece = Pnn::Piece.parse("+q'")

  raise "Wrong string representation" unless piece.to_s == "+q'"
end

# ============================================================================
# State Manipulation Tests
# ============================================================================

run_test("Enhance simple piece") do
  piece = Pnn::Piece.parse("k")
  enhanced = piece.enhance

  raise "Should be enhanced" unless enhanced.enhanced?
  raise "Should not be diminished" if enhanced.diminished?
  raise "Should not be intermediate" if enhanced.intermediate?
  raise "Wrong string representation" unless enhanced.to_s == "+k"
  raise "Original should be unchanged" if piece.enhanced?
end

run_test("Enhance already enhanced piece") do
  piece = Pnn::Piece.parse("+k")
  enhanced = piece.enhance

  # Should return the same object when no change needed
  raise "Should return same object" unless enhanced.equal?(piece)
  raise "Should still be enhanced" unless enhanced.enhanced?
  raise "Wrong string representation" unless enhanced.to_s == "+k"
end

run_test("Enhance diminished piece replaces diminished state") do
  piece = Pnn::Piece.parse("-k")
  enhanced = piece.enhance

  raise "Should be enhanced" unless enhanced.enhanced?
  raise "Should not be diminished" if enhanced.diminished?
  raise "Wrong string representation" unless enhanced.to_s == "+k"
end

run_test("Unenhance enhanced piece") do
  piece = Pnn::Piece.parse("+k")
  unenhanced = piece.unenhance

  raise "Should not be enhanced" if unenhanced.enhanced?
  raise "Should not be diminished" if unenhanced.diminished?
  raise "Should not be intermediate" if unenhanced.intermediate?
  raise "Wrong string representation" unless unenhanced.to_s == "k"
end

run_test("Unenhance non-enhanced piece") do
  piece = Pnn::Piece.parse("k")
  unenhanced = piece.unenhance

  # Should return the same object when no change needed
  raise "Should return same object" unless unenhanced.equal?(piece)
  raise "Wrong string representation" unless unenhanced.to_s == "k"
end

run_test("Diminish simple piece") do
  piece = Pnn::Piece.parse("K")
  diminished = piece.diminish

  raise "Should not be enhanced" if diminished.enhanced?
  raise "Should be diminished" unless diminished.diminished?
  raise "Should not be intermediate" if diminished.intermediate?
  raise "Wrong string representation" unless diminished.to_s == "-K"
end

run_test("Diminish already diminished piece") do
  piece = Pnn::Piece.parse("-K")
  diminished = piece.diminish

  # Should return the same object when no change needed
  raise "Should return same object" unless diminished.equal?(piece)
  raise "Should still be diminished" unless diminished.diminished?
  raise "Wrong string representation" unless diminished.to_s == "-K"
end

run_test("Diminish enhanced piece replaces enhanced state") do
  piece = Pnn::Piece.parse("+K")
  diminished = piece.diminish

  raise "Should not be enhanced" if diminished.enhanced?
  raise "Should be diminished" unless diminished.diminished?
  raise "Wrong string representation" unless diminished.to_s == "-K"
end

run_test("Undiminish diminished piece") do
  piece = Pnn::Piece.parse("-K")
  undiminished = piece.undiminish

  raise "Should not be enhanced" if undiminished.enhanced?
  raise "Should not be diminished" if undiminished.diminished?
  raise "Should not be intermediate" if undiminished.intermediate?
  raise "Wrong string representation" unless undiminished.to_s == "K"
end

run_test("Undiminish non-diminished piece") do
  piece = Pnn::Piece.parse("K")
  undiminished = piece.undiminish

  # Should return the same object when no change needed
  raise "Should return same object" unless undiminished.equal?(piece)
  raise "Wrong string representation" unless undiminished.to_s == "K"
end

run_test("Add intermediate state") do
  piece = Pnn::Piece.parse("k")
  intermediate = piece.intermediate

  raise "Should not be enhanced" if intermediate.enhanced?
  raise "Should not be diminished" if intermediate.diminished?
  raise "Should be intermediate" unless intermediate.intermediate?
  raise "Wrong string representation" unless intermediate.to_s == "k'"
end

run_test("Add intermediate to already intermediate piece") do
  piece = Pnn::Piece.parse("k'")
  intermediate = piece.intermediate

  # Should return the same object when no change needed
  raise "Should return same object" unless intermediate.equal?(piece)
  raise "Should still be intermediate" unless intermediate.intermediate?
  raise "Wrong string representation" unless intermediate.to_s == "k'"
end

run_test("Remove intermediate state") do
  piece = Pnn::Piece.parse("k'")
  unintermediate = piece.unintermediate

  raise "Should not be enhanced" if unintermediate.enhanced?
  raise "Should not be diminished" if unintermediate.diminished?
  raise "Should not be intermediate" if unintermediate.intermediate?
  raise "Wrong string representation" unless unintermediate.to_s == "k"
end

run_test("Remove intermediate from non-intermediate piece") do
  piece = Pnn::Piece.parse("k")
  unintermediate = piece.unintermediate

  # Should return the same object when no change needed
  raise "Should return same object" unless unintermediate.equal?(piece)
  raise "Wrong string representation" unless unintermediate.to_s == "k"
end

run_test("Get bare piece from complex piece") do
  piece = Pnn::Piece.parse("+k'")
  bare = piece.bare

  raise "Should not be enhanced" if bare.enhanced?
  raise "Should not be diminished" if bare.diminished?
  raise "Should not be intermediate" if bare.intermediate?
  raise "Should be bare" unless bare.bare?
  raise "Wrong string representation" unless bare.to_s == "k"
end

run_test("Get bare from already bare piece") do
  piece = Pnn::Piece.parse("k")
  bare = piece.bare

  # Should return the same object when no change needed
  raise "Should return same object" unless bare.equal?(piece)
  raise "Should be bare" unless bare.bare?
  raise "Wrong string representation" unless bare.to_s == "k"
end

# ============================================================================
# Ownership Change Tests
# ============================================================================

run_test("Flip ownership - lowercase to uppercase") do
  piece = Pnn::Piece.parse("k")
  flipped = piece.flip

  raise "Wrong letter" unless flipped.letter == "K"
  raise "Should be uppercase" unless flipped.uppercase?
  raise "Should not be lowercase" if flipped.lowercase?
  raise "Wrong string representation" unless flipped.to_s == "K"
  raise "Original should be unchanged" unless piece.letter == "k"
end

run_test("Flip ownership - uppercase to lowercase") do
  piece = Pnn::Piece.parse("K")
  flipped = piece.flip

  raise "Wrong letter" unless flipped.letter == "k"
  raise "Should be lowercase" unless flipped.lowercase?
  raise "Should not be uppercase" if flipped.uppercase?
  raise "Wrong string representation" unless flipped.to_s == "k"
  raise "Original should be unchanged" unless piece.letter == "K"
end

run_test("Flip ownership preserves modifiers") do
  piece = Pnn::Piece.parse("+k'")
  flipped = piece.flip

  raise "Wrong letter" unless flipped.letter == "K"
  raise "Should be enhanced" unless flipped.enhanced?
  raise "Should be intermediate" unless flipped.intermediate?
  raise "Wrong string representation" unless flipped.to_s == "+K'"
end

run_test("Chain multiple operations") do
  piece = Pnn::Piece.parse("k")
  result = piece.enhance.intermediate.flip

  raise "Wrong letter" unless result.letter == "K"
  raise "Should be enhanced" unless result.enhanced?
  raise "Should be intermediate" unless result.intermediate?
  raise "Should be uppercase" unless result.uppercase?
  raise "Wrong string representation" unless result.to_s == "+K'"
end

# ============================================================================
# Error Handling Tests
# ============================================================================

run_test("Invalid PNN string - empty") do
  exception_raised = false
  begin
    Pnn::Piece.parse("")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid PNN string - multiple letters") do
  exception_raised = false
  begin
    Pnn::Piece.parse("kq")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid PNN string - double prefix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("++k")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid PNN string - double suffix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("k''")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid PNN string - invalid prefix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("*k")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid PNN string - invalid suffix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("k@")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid PNN string - number") do
  exception_raised = false
  begin
    Pnn::Piece.parse("1")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid piece creation - both enhanced and diminished") do
  exception_raised = false
  begin
    Pnn::Piece.new("k", enhanced: true, diminished: true)
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("cannot be both enhanced and diminished")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid piece creation - invalid letter") do
  exception_raised = false
  begin
    Pnn::Piece.new("1")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Letter must be a single ASCII letter")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

# ============================================================================
# Equality and Hashing Tests
# ============================================================================

run_test("Piece equality - same pieces") do
  piece1 = Pnn::Piece.parse("k")
  piece2 = Pnn::Piece.parse("k")

  raise "Pieces should be equal" unless piece1 == piece2
  raise "Hash should be equal" unless piece1.hash == piece2.hash
end

run_test("Piece equality - different letters") do
  piece1 = Pnn::Piece.parse("k")
  piece2 = Pnn::Piece.parse("q")

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Piece equality - different case") do
  piece1 = Pnn::Piece.parse("k")
  piece2 = Pnn::Piece.parse("K")

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Piece equality - different modifiers") do
  piece1 = Pnn::Piece.parse("k")
  piece2 = Pnn::Piece.parse("+k")

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Piece equality - complex pieces") do
  piece1 = Pnn::Piece.parse("+k'")
  piece2 = Pnn::Piece.parse("+k'")

  raise "Pieces should be equal" unless piece1 == piece2
  raise "Hash should be equal" unless piece1.hash == piece2.hash
end

run_test("Piece equality - not a piece") do
  piece = Pnn::Piece.parse("k")

  raise "Should not be equal to string" if piece == "k"
  raise "Should not be equal to nil" if piece.nil?
end

# ============================================================================
# Constructor vs Parse Equivalence Tests
# ============================================================================

run_test("Constructor creates equivalent objects to parser") do
  # Simple piece
  parsed = Pnn::Piece.parse("k")
  constructed = Pnn::Piece.new("k")
  raise "Parsed and constructed should be equal" unless parsed == constructed

  # Enhanced piece
  parsed = Pnn::Piece.parse("+K")
  constructed = Pnn::Piece.new("K", enhanced: true)
  raise "Parsed and constructed enhanced should be equal" unless parsed == constructed

  # Complex piece
  parsed = Pnn::Piece.parse("-q'")
  constructed = Pnn::Piece.new("q", diminished: true, intermediate: true)
  raise "Parsed and constructed complex should be equal" unless parsed == constructed
end

# ============================================================================
# Legacy API Tests
# ============================================================================

run_test("Legacy valid? - valid pieces") do
  raise "Should be valid" unless Pnn.valid?("k")
  raise "Should be valid" unless Pnn.valid?("+k")
  raise "Should be valid" unless Pnn.valid?("-K")
  raise "Should be valid" unless Pnn.valid?("p'")
  raise "Should be valid" unless Pnn.valid?("+q'")
end

run_test("Legacy valid? - invalid pieces") do
  raise "Should be invalid" if Pnn.valid?("")
  raise "Should be invalid" if Pnn.valid?("kq")
  raise "Should be invalid" if Pnn.valid?("++k")
  raise "Should be invalid" if Pnn.valid?("k''")
  raise "Should be invalid" if Pnn.valid?("1")
end

run_test("Convenience piece method") do
  piece = Pnn.piece("k", enhanced: true, intermediate: true)

  raise "Wrong letter" unless piece.letter == "k"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Wrong string representation" unless piece.to_s == "+k'"
end

# ============================================================================
# Inspection and String Representation Tests
# ============================================================================

run_test("Piece inspection - simple piece") do
  piece = Pnn::Piece.parse("k")
  inspection = piece.inspect

  raise "Should contain class name" unless inspection.include?("Pnn::Piece")
  raise "Should contain letter" unless inspection.include?("letter='k'")
  raise "Should not contain modifiers for simple piece" if inspection.include?("enhanced=true")
end

run_test("Piece inspection - complex piece") do
  piece = Pnn::Piece.parse("+k'")
  inspection = piece.inspect

  raise "Should contain class name" unless inspection.include?("Pnn::Piece")
  raise "Should contain letter" unless inspection.include?("letter='k'")
  raise "Should contain enhanced" unless inspection.include?("enhanced=true")
  raise "Should contain intermediate" unless inspection.include?("intermediate=true")
  raise "Should not contain diminished" if inspection.include?("diminished=true")
end

# ============================================================================
# Edge Cases and Special Scenarios
# ============================================================================

run_test("All letters are valid") do
  # Test all uppercase letters
  ("A".."Z").each do |letter|
    piece = Pnn::Piece.parse(letter)
    raise "Failed for letter #{letter}" unless piece.letter == letter
  end

  # Test all lowercase letters
  ("a".."z").each do |letter|
    piece = Pnn::Piece.parse(letter)
    raise "Failed for letter #{letter}" unless piece.letter == letter
  end
end

run_test("Immutability - original object unchanged") do
  original = Pnn::Piece.parse("k")
  original.enhance
  original.intermediate
  original.flip

  # Original should remain unchanged
  raise "Original should not be enhanced" if original.enhanced?
  raise "Original should not be intermediate" if original.intermediate?
  raise "Original should still be lowercase" unless original.lowercase?
  raise "Original string should be unchanged" unless original.to_s == "k"
end

run_test("Round-trip conversion") do
  test_cases = ["k", "K", "+k", "-K", "p'", "+q'", "-R'"]

  test_cases.each do |pnn_string|
    piece = Pnn::Piece.parse(pnn_string)
    converted = piece.to_s

    raise "Round-trip failed for #{pnn_string}: got #{converted}" unless converted == pnn_string
  end
end

run_test("State transitions maintain letter and other states") do
  piece = Pnn::Piece.parse("+k'")

  # Remove enhanced state, should keep intermediate
  unenhanced = piece.unenhance
  raise "Should keep letter" unless unenhanced.letter == "k"
  raise "Should keep intermediate" unless unenhanced.intermediate?
  raise "Should not be enhanced" if unenhanced.enhanced?

  # Remove intermediate state, should keep enhanced
  original_enhanced = piece.unintermediate
  raise "Should keep letter" unless original_enhanced.letter == "k"
  raise "Should keep enhanced" unless original_enhanced.enhanced?
  raise "Should not be intermediate" if original_enhanced.intermediate?
end

puts
puts "All PNN tests passed!"
puts
