# frozen_string_literal: true

require "simplecov"
SimpleCov.start

# Tests for Pnn::Piece class
#
# This test suite focuses specifically on the Pnn::Piece class and provides
# comprehensive coverage of all piece functionality including:
# - Piece creation and parsing
# - State manipulation methods (enhanced, diminished, intermediate)
# - Ownership changes and case flipping
# - Immutability guarantees
# - Error handling and validation
# - Object equality, hashing, and inspection
# - Edge cases and boundary conditions
#
# These tests complement the main test suite by providing focused,
# granular testing of the core Piece class functionality.

require_relative "../../lib/pnn/piece"

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
puts "Tests for Pnn::Piece class"
puts

# ============================================================================
# Constructor Tests
# ============================================================================

run_test("Create simple piece with letter only") do
  piece = Pnn::Piece.new("k")

  raise "Wrong letter" unless piece.letter == "k"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should be bare" unless piece.bare?
  raise "Should be lowercase" unless piece.lowercase?
  raise "Should not be uppercase" if piece.uppercase?
end

run_test("Create enhanced piece") do
  piece = Pnn::Piece.new("K", enhanced: true)

  raise "Wrong letter" unless piece.letter == "K"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
  raise "Should be uppercase" unless piece.uppercase?
  raise "Should not be lowercase" if piece.lowercase?
end

run_test("Create diminished piece") do
  piece = Pnn::Piece.new("q", diminished: true)

  raise "Wrong letter" unless piece.letter == "q"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should be diminished" unless piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Create intermediate piece") do
  piece = Pnn::Piece.new("R", intermediate: true)

  raise "Wrong letter" unless piece.letter == "R"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Create complex piece with multiple states") do
  piece = Pnn::Piece.new("p", enhanced: true, intermediate: true)

  raise "Wrong letter" unless piece.letter == "p"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Create piece with diminished and intermediate") do
  piece = Pnn::Piece.new("N", diminished: true, intermediate: true)

  raise "Wrong letter" unless piece.letter == "N"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should be diminished" unless piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

# ============================================================================
# Parser Tests - Simple Cases
# ============================================================================

run_test("Parse lowercase letter") do
  piece = Pnn::Piece.parse("b")

  raise "Wrong letter" unless piece.letter == "b"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should be bare" unless piece.bare?
end

run_test("Parse uppercase letter") do
  piece = Pnn::Piece.parse("B")

  raise "Wrong letter" unless piece.letter == "B"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should be bare" unless piece.bare?
end

# ============================================================================
# Parser Tests - Enhanced States
# ============================================================================

run_test("Parse enhanced lowercase") do
  piece = Pnn::Piece.parse("+n")

  raise "Wrong letter" unless piece.letter == "n"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse enhanced uppercase") do
  piece = Pnn::Piece.parse("+Q")

  raise "Wrong letter" unless piece.letter == "Q"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

# ============================================================================
# Parser Tests - Diminished States
# ============================================================================

run_test("Parse diminished lowercase") do
  piece = Pnn::Piece.parse("-r")

  raise "Wrong letter" unless piece.letter == "r"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should be diminished" unless piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse diminished uppercase") do
  piece = Pnn::Piece.parse("-B")

  raise "Wrong letter" unless piece.letter == "B"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should be diminished" unless piece.diminished?
  raise "Should not be intermediate" if piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

# ============================================================================
# Parser Tests - Intermediate States
# ============================================================================

run_test("Parse intermediate lowercase") do
  piece = Pnn::Piece.parse("p'")

  raise "Wrong letter" unless piece.letter == "p"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse intermediate uppercase") do
  piece = Pnn::Piece.parse("K'")

  raise "Wrong letter" unless piece.letter == "K"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

# ============================================================================
# Parser Tests - Combined States
# ============================================================================

run_test("Parse enhanced and intermediate") do
  piece = Pnn::Piece.parse("+k'")

  raise "Wrong letter" unless piece.letter == "k"
  raise "Should be enhanced" unless piece.enhanced?
  raise "Should not be diminished" if piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

run_test("Parse diminished and intermediate") do
  piece = Pnn::Piece.parse("-Q'")

  raise "Wrong letter" unless piece.letter == "Q"
  raise "Should not be enhanced" if piece.enhanced?
  raise "Should be diminished" unless piece.diminished?
  raise "Should be intermediate" unless piece.intermediate?
  raise "Should not be bare" if piece.bare?
end

# ============================================================================
# String Representation Tests
# ============================================================================

run_test("Simple piece to_s") do
  piece = Pnn::Piece.new("k")

  raise "Wrong string representation" unless piece.to_s == "k"
end

run_test("Enhanced piece to_s") do
  piece = Pnn::Piece.new("p", enhanced: true)

  raise "Wrong string representation" unless piece.to_s == "+p"
end

run_test("Diminished piece to_s") do
  piece = Pnn::Piece.new("R", diminished: true)

  raise "Wrong string representation" unless piece.to_s == "-R"
end

run_test("Intermediate piece to_s") do
  piece = Pnn::Piece.new("k", intermediate: true)

  raise "Wrong string representation" unless piece.to_s == "k'"
end

run_test("Enhanced intermediate piece to_s") do
  piece = Pnn::Piece.new("q", enhanced: true, intermediate: true)

  raise "Wrong string representation" unless piece.to_s == "+q'"
end

run_test("Diminished intermediate piece to_s") do
  piece = Pnn::Piece.new("B", diminished: true, intermediate: true)

  raise "Wrong string representation" unless piece.to_s == "-B'"
end

# ============================================================================
# Enhance/Unenhance Tests
# ============================================================================

run_test("Enhance simple piece") do
  original = Pnn::Piece.new("k")
  enhanced = original.enhance

  raise "Should be enhanced" unless enhanced.enhanced?
  raise "Should not be diminished" if enhanced.diminished?
  raise "Should not be intermediate" if enhanced.intermediate?
  raise "Wrong letter" unless enhanced.letter == "k"
  raise "Wrong string" unless enhanced.to_s == "+k"

  # Check immutability
  raise "Original should be unchanged" if original.enhanced?
end

run_test("Enhance already enhanced piece returns self") do
  original = Pnn::Piece.new("k", enhanced: true)
  enhanced = original.enhance

  raise "Should return same object" unless enhanced.equal?(original)
end

run_test("Enhance diminished piece replaces state") do
  original = Pnn::Piece.new("k", diminished: true)
  enhanced = original.enhance

  raise "Should be enhanced" unless enhanced.enhanced?
  raise "Should not be diminished" if enhanced.diminished?
  raise "Wrong string" unless enhanced.to_s == "+k"
end

run_test("Enhance intermediate piece preserves intermediate") do
  original = Pnn::Piece.new("k", intermediate: true)
  enhanced = original.enhance

  raise "Should be enhanced" unless enhanced.enhanced?
  raise "Should be intermediate" unless enhanced.intermediate?
  raise "Should not be diminished" if enhanced.diminished?
  raise "Wrong string" unless enhanced.to_s == "+k'"
end

run_test("Unenhance enhanced piece") do
  original = Pnn::Piece.new("k", enhanced: true)
  unenhanced = original.unenhance

  raise "Should not be enhanced" if unenhanced.enhanced?
  raise "Should not be diminished" if unenhanced.diminished?
  raise "Should not be intermediate" if unenhanced.intermediate?
  raise "Wrong string" unless unenhanced.to_s == "k"

  # Check immutability
  raise "Original should be unchanged" unless original.enhanced?
end

run_test("Unenhance non-enhanced piece returns self") do
  original = Pnn::Piece.new("k")
  unenhanced = original.unenhance

  raise "Should return same object" unless unenhanced.equal?(original)
end

run_test("Unenhance preserves other states") do
  original = Pnn::Piece.new("k", enhanced: true, intermediate: true)
  unenhanced = original.unenhance

  raise "Should not be enhanced" if unenhanced.enhanced?
  raise "Should be intermediate" unless unenhanced.intermediate?
  raise "Wrong string" unless unenhanced.to_s == "k'"
end

# ============================================================================
# Diminish/Undiminish Tests
# ============================================================================

run_test("Diminish simple piece") do
  original = Pnn::Piece.new("K")
  diminished = original.diminish

  raise "Should not be enhanced" if diminished.enhanced?
  raise "Should be diminished" unless diminished.diminished?
  raise "Should not be intermediate" if diminished.intermediate?
  raise "Wrong letter" unless diminished.letter == "K"
  raise "Wrong string" unless diminished.to_s == "-K"

  # Check immutability
  raise "Original should be unchanged" if original.diminished?
end

run_test("Diminish already diminished piece returns self") do
  original = Pnn::Piece.new("K", diminished: true)
  diminished = original.diminish

  raise "Should return same object" unless diminished.equal?(original)
end

run_test("Diminish enhanced piece replaces state") do
  original = Pnn::Piece.new("K", enhanced: true)
  diminished = original.diminish

  raise "Should not be enhanced" if diminished.enhanced?
  raise "Should be diminished" unless diminished.diminished?
  raise "Wrong string" unless diminished.to_s == "-K"
end

run_test("Diminish intermediate piece preserves intermediate") do
  original = Pnn::Piece.new("K", intermediate: true)
  diminished = original.diminish

  raise "Should not be enhanced" if diminished.enhanced?
  raise "Should be diminished" unless diminished.diminished?
  raise "Should be intermediate" unless diminished.intermediate?
  raise "Wrong string" unless diminished.to_s == "-K'"
end

run_test("Undiminish diminished piece") do
  original = Pnn::Piece.new("K", diminished: true)
  undiminished = original.undiminish

  raise "Should not be enhanced" if undiminished.enhanced?
  raise "Should not be diminished" if undiminished.diminished?
  raise "Should not be intermediate" if undiminished.intermediate?
  raise "Wrong string" unless undiminished.to_s == "K"

  # Check immutability
  raise "Original should be unchanged" unless original.diminished?
end

run_test("Undiminish non-diminished piece returns self") do
  original = Pnn::Piece.new("K")
  undiminished = original.undiminish

  raise "Should return same object" unless undiminished.equal?(original)
end

# ============================================================================
# Intermediate/Unintermediate Tests
# ============================================================================

run_test("Add intermediate to simple piece") do
  original = Pnn::Piece.new("p")
  intermediate = original.intermediate

  raise "Should not be enhanced" if intermediate.enhanced?
  raise "Should not be diminished" if intermediate.diminished?
  raise "Should be intermediate" unless intermediate.intermediate?
  raise "Wrong letter" unless intermediate.letter == "p"
  raise "Wrong string" unless intermediate.to_s == "p'"

  # Check immutability
  raise "Original should be unchanged" if original.intermediate?
end

run_test("Add intermediate to already intermediate piece returns self") do
  original = Pnn::Piece.new("p", intermediate: true)
  intermediate = original.intermediate

  raise "Should return same object" unless intermediate.equal?(original)
end

run_test("Add intermediate preserves other states") do
  original = Pnn::Piece.new("p", enhanced: true)
  intermediate = original.intermediate

  raise "Should be enhanced" unless intermediate.enhanced?
  raise "Should be intermediate" unless intermediate.intermediate?
  raise "Should not be diminished" if intermediate.diminished?
  raise "Wrong string" unless intermediate.to_s == "+p'"
end

run_test("Remove intermediate from intermediate piece") do
  original = Pnn::Piece.new("p", intermediate: true)
  unintermediate = original.unintermediate

  raise "Should not be enhanced" if unintermediate.enhanced?
  raise "Should not be diminished" if unintermediate.diminished?
  raise "Should not be intermediate" if unintermediate.intermediate?
  raise "Wrong string" unless unintermediate.to_s == "p"

  # Check immutability
  raise "Original should be unchanged" unless original.intermediate?
end

run_test("Remove intermediate from non-intermediate piece returns self") do
  original = Pnn::Piece.new("p")
  unintermediate = original.unintermediate

  raise "Should return same object" unless unintermediate.equal?(original)
end

# ============================================================================
# Bare Tests
# ============================================================================

run_test("Get bare from simple piece returns self") do
  original = Pnn::Piece.new("k")
  bare = original.bare

  raise "Should return same object" unless bare.equal?(original)
  raise "Should be bare" unless bare.bare?
end

run_test("Get bare from enhanced piece") do
  original = Pnn::Piece.new("k", enhanced: true)
  bare = original.bare

  raise "Should not be enhanced" if bare.enhanced?
  raise "Should not be diminished" if bare.diminished?
  raise "Should not be intermediate" if bare.intermediate?
  raise "Should be bare" unless bare.bare?
  raise "Wrong letter" unless bare.letter == "k"
  raise "Wrong string" unless bare.to_s == "k"

  # Check immutability
  raise "Original should be unchanged" unless original.enhanced?
end

run_test("Get bare from complex piece") do
  original = Pnn::Piece.new("Q", diminished: true, intermediate: true)
  bare = original.bare

  raise "Should not be enhanced" if bare.enhanced?
  raise "Should not be diminished" if bare.diminished?
  raise "Should not be intermediate" if bare.intermediate?
  raise "Should be bare" unless bare.bare?
  raise "Wrong letter" unless bare.letter == "Q"
  raise "Wrong string" unless bare.to_s == "Q"
end

# ============================================================================
# Flip Tests
# ============================================================================

run_test("Flip lowercase to uppercase") do
  original = Pnn::Piece.new("k")
  flipped = original.flip

  raise "Wrong letter" unless flipped.letter == "K"
  raise "Should be uppercase" unless flipped.uppercase?
  raise "Should not be lowercase" if flipped.lowercase?
  raise "Wrong string" unless flipped.to_s == "K"

  # Check immutability
  raise "Original should be unchanged" unless original.letter == "k"
end

run_test("Flip uppercase to lowercase") do
  original = Pnn::Piece.new("K")
  flipped = original.flip

  raise "Wrong letter" unless flipped.letter == "k"
  raise "Should be lowercase" unless flipped.lowercase?
  raise "Should not be uppercase" if flipped.uppercase?
  raise "Wrong string" unless flipped.to_s == "k"
end

run_test("Flip preserves all modifiers") do
  original = Pnn::Piece.new("p", enhanced: true, intermediate: true)
  flipped = original.flip

  raise "Wrong letter" unless flipped.letter == "P"
  raise "Should be enhanced" unless flipped.enhanced?
  raise "Should be intermediate" unless flipped.intermediate?
  raise "Should not be diminished" if flipped.diminished?
  raise "Wrong string" unless flipped.to_s == "+P'"
end

run_test("Double flip returns equivalent piece") do
  original = Pnn::Piece.new("k", diminished: true, intermediate: true)
  double_flipped = original.flip.flip

  raise "Should be equal after double flip" unless original == double_flipped
  raise "Should have same string representation" unless original.to_s == double_flipped.to_s
end

# ============================================================================
# Validation and Error Tests
# ============================================================================

run_test("Invalid letter - empty string") do
  exception_raised = false
  begin
    Pnn::Piece.new("")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Letter must be a single ASCII letter")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid letter - multiple characters") do
  exception_raised = false
  begin
    Pnn::Piece.new("kq")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Letter must be a single ASCII letter")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid letter - number") do
  exception_raised = false
  begin
    Pnn::Piece.new("1")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Letter must be a single ASCII letter")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid letter - special character") do
  exception_raised = false
  begin
    Pnn::Piece.new("@")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Letter must be a single ASCII letter")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Invalid state combination - both enhanced and diminished") do
  exception_raised = false
  begin
    Pnn::Piece.new("k", enhanced: true, diminished: true)
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("cannot be both enhanced and diminished")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

# ============================================================================
# Parse Error Tests
# ============================================================================

run_test("Parse invalid - empty string") do
  exception_raised = false
  begin
    Pnn::Piece.parse("")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Parse invalid - multiple letters") do
  exception_raised = false
  begin
    Pnn::Piece.parse("kq")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Parse invalid - double prefix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("++k")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Parse invalid - double suffix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("k''")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Parse invalid - wrong prefix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("*k")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

run_test("Parse invalid - wrong suffix") do
  exception_raised = false
  begin
    Pnn::Piece.parse("k@")
  rescue ArgumentError => e
    exception_raised = true
    raise "Wrong error message" unless e.message.include?("Invalid PNN string")
  end

  raise "Expected ArgumentError to be raised" unless exception_raised
end

# ============================================================================
# Equality and Hash Tests
# ============================================================================

run_test("Equal pieces have same hash") do
  piece1 = Pnn::Piece.new("k", enhanced: true)
  piece2 = Pnn::Piece.new("k", enhanced: true)

  raise "Pieces should be equal" unless piece1 == piece2
  raise "Hashes should be equal" unless piece1.hash == piece2.hash
end

run_test("Different letters are not equal") do
  piece1 = Pnn::Piece.new("k")
  piece2 = Pnn::Piece.new("q")

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Different cases are not equal") do
  piece1 = Pnn::Piece.new("k")
  piece2 = Pnn::Piece.new("K")

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Different enhanced states are not equal") do
  piece1 = Pnn::Piece.new("k")
  piece2 = Pnn::Piece.new("k", enhanced: true)

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Different diminished states are not equal") do
  piece1 = Pnn::Piece.new("k")
  piece2 = Pnn::Piece.new("k", diminished: true)

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Different intermediate states are not equal") do
  piece1 = Pnn::Piece.new("k")
  piece2 = Pnn::Piece.new("k", intermediate: true)

  raise "Pieces should not be equal" if piece1 == piece2
end

run_test("Not equal to non-piece objects") do
  piece = Pnn::Piece.new("k")

  raise "Should not equal string" if piece == "k"
  raise "Should not equal nil" if piece.nil?
  raise "Should not equal number" if piece == 1
  raise "Should not equal array" if piece == []
end

# ============================================================================
# Inspection Tests
# ============================================================================

run_test("Inspect simple piece") do
  piece = Pnn::Piece.new("k")
  inspection = piece.inspect

  raise "Should contain class name" unless inspection.include?("Pnn::Piece")
  raise "Should contain letter" unless inspection.include?("letter='k'")
  raise "Should not contain modifiers" if inspection.include?("enhanced=true")
  raise "Should not contain modifiers" if inspection.include?("diminished=true")
  raise "Should not contain modifiers" if inspection.include?("intermediate=true")
end

run_test("Inspect enhanced piece") do
  piece = Pnn::Piece.new("k", enhanced: true)
  inspection = piece.inspect

  raise "Should contain class name" unless inspection.include?("Pnn::Piece")
  raise "Should contain letter" unless inspection.include?("letter='k'")
  raise "Should contain enhanced" unless inspection.include?("enhanced=true")
  raise "Should not contain diminished" if inspection.include?("diminished=true")
  raise "Should not contain intermediate" if inspection.include?("intermediate=true")
end

run_test("Inspect complex piece") do
  piece = Pnn::Piece.new("Q", diminished: true, intermediate: true)
  inspection = piece.inspect

  raise "Should contain class name" unless inspection.include?("Pnn::Piece")
  raise "Should contain letter" unless inspection.include?("letter='Q'")
  raise "Should not contain enhanced" if inspection.include?("enhanced=true")
  raise "Should contain diminished" unless inspection.include?("diminished=true")
  raise "Should contain intermediate" unless inspection.include?("intermediate=true")
end

# ============================================================================
# Immutability Tests
# ============================================================================

run_test("Piece objects are frozen") do
  piece = Pnn::Piece.new("k")

  raise "Piece should be frozen" unless piece.frozen?
end

run_test("Letter is frozen") do
  piece = Pnn::Piece.new("k")

  raise "Letter should be frozen" unless piece.letter.frozen?
end

run_test("State manipulation returns different objects") do
  original = Pnn::Piece.new("k")

  enhanced = original.enhance
  diminished = original.diminish
  intermediate = original.intermediate
  flipped = original.flip
  bare = original.bare

  raise "Enhanced should be different object" if enhanced.equal?(original)
  raise "Diminished should be different object" if diminished.equal?(original)
  raise "Intermediate should be different object" if intermediate.equal?(original)
  raise "Flipped should be different object" if flipped.equal?(original)
  raise "Bare should be same object" unless bare.equal?(original) # bare of bare piece returns self
end

run_test("Original object unchanged after operations") do
  original = Pnn::Piece.new("k")

  # Perform various operations
  original.enhance
  original.diminish
  original.intermediate
  original.flip
  original.bare

  # Original should remain unchanged
  raise "Original should not be enhanced" if original.enhanced?
  raise "Original should not be diminished" if original.diminished?
  raise "Original should not be intermediate" if original.intermediate?
  raise "Original letter should be unchanged" unless original.letter == "k"
  raise "Original should be bare" unless original.bare?
end

# ============================================================================
# Round-trip Conversion Tests
# ============================================================================

run_test("Round-trip all single letters") do
  ("a".."z").each do |letter|
    piece = Pnn::Piece.parse(letter)
    converted = piece.to_s
    raise "Round-trip failed for #{letter}" unless converted == letter
  end

  ("A".."Z").each do |letter|
    piece = Pnn::Piece.parse(letter)
    converted = piece.to_s
    raise "Round-trip failed for #{letter}" unless converted == letter
  end
end

run_test("Round-trip all modifier combinations") do
  test_cases = [
    "k", "K", "+k", "+K", "-k", "-K",
    "p'", "P'", "+p'", "+P'", "-p'", "-P'"
  ]

  test_cases.each do |pnn_string|
    piece = Pnn::Piece.parse(pnn_string)
    converted = piece.to_s
    raise "Round-trip failed for #{pnn_string}: got #{converted}" unless converted == pnn_string
  end
end

run_test("Round-trip after state changes") do
  original = Pnn::Piece.parse("k")

  # Apply various transformations and check round-trip
  enhanced = original.enhance
  raise "Enhanced round-trip failed" unless Pnn::Piece.parse(enhanced.to_s) == enhanced

  diminished = original.diminish
  raise "Diminished round-trip failed" unless Pnn::Piece.parse(diminished.to_s) == diminished

  intermediate = original.intermediate
  raise "Intermediate round-trip failed" unless Pnn::Piece.parse(intermediate.to_s) == intermediate

  flipped = original.flip
  raise "Flipped round-trip failed" unless Pnn::Piece.parse(flipped.to_s) == flipped

  complex = original.enhance.intermediate.flip
  raise "Complex round-trip failed" unless Pnn::Piece.parse(complex.to_s) == complex
end

# ============================================================================
# Method Chaining Tests
# ============================================================================

run_test("Chain enhance and intermediate") do
  piece = Pnn::Piece.new("k")
  result = piece.enhance.intermediate

  raise "Should be enhanced" unless result.enhanced?
  raise "Should be intermediate" unless result.intermediate?
  raise "Should not be diminished" if result.diminished?
  raise "Wrong string" unless result.to_s == "+k'"
end

run_test("Chain diminish and intermediate") do
  piece = Pnn::Piece.new("Q")
  result = piece.diminish.intermediate

  raise "Should not be enhanced" if result.enhanced?
  raise "Should be diminished" unless result.diminished?
  raise "Should be intermediate" unless result.intermediate?
  raise "Wrong string" unless result.to_s == "-Q'"
end

run_test("Chain enhance, flip, and intermediate") do
  piece = Pnn::Piece.new("p")
  result = piece.enhance.flip.intermediate

  raise "Wrong letter" unless result.letter == "P"
  raise "Should be enhanced" unless result.enhanced?
  raise "Should be intermediate" unless result.intermediate?
  raise "Should not be diminished" if result.diminished?
  raise "Wrong string" unless result.to_s == "+P'"
end

run_test("Chain bare after complex operations") do
  piece = Pnn::Piece.new("k")
  result = piece.enhance.intermediate.flip.bare

  raise "Wrong letter" unless result.letter == "K"
  raise "Should not be enhanced" if result.enhanced?
  raise "Should not be diminished" if result.diminished?
  raise "Should not be intermediate" if result.intermediate?
  raise "Should be bare" unless result.bare?
  raise "Wrong string" unless result.to_s == "K"
end

run_test("Chain opposite operations cancel out") do
  piece = Pnn::Piece.new("k")

  # enhance then unenhance
  result1 = piece.enhance.unenhance
  raise "Should equal original" unless result1 == piece

  # diminish then undiminish
  result2 = piece.diminish.undiminish
  raise "Should equal original" unless result2 == piece

  # intermediate then unintermediate
  result3 = piece.intermediate.unintermediate
  raise "Should equal original" unless result3 == piece

  # flip twice
  result4 = piece.flip.flip
  raise "Should equal original" unless result4 == piece
end

# ============================================================================
# Edge Cases and Boundary Tests
# ============================================================================

run_test("All letters work as expected") do
  # Test a few specific letters that might cause issues
  special_letters = %w[a z A Z m M]

  special_letters.each do |letter|
    piece = Pnn::Piece.new(letter)
    raise "Letter #{letter} failed basic test" unless piece.letter == letter

    # Test with all modifiers
    enhanced = piece.enhance
    raise "Enhanced #{letter} failed" unless enhanced.to_s == "+#{letter}"

    diminished = piece.diminish
    raise "Diminished #{letter} failed" unless diminished.to_s == "-#{letter}"

    intermediate = piece.intermediate
    raise "Intermediate #{letter} failed" unless intermediate.to_s == "#{letter}'"
  end
end

run_test("State queries are consistent") do
  # Test simple piece
  simple = Pnn::Piece.new("k")
  raise "Simple piece should be bare" unless simple.bare?
  raise "Bare query mismatch" unless simple.bare? == (!simple.enhanced? && !simple.diminished? && !simple.intermediate?)

  # Test complex piece
  complex = Pnn::Piece.new("K", enhanced: true, intermediate: true)
  raise "Complex piece should not be bare" if complex.bare?
  unless complex.bare? == (!complex.enhanced? && !complex.diminished? && !complex.intermediate?)
    raise "Bare query mismatch"
  end
end

run_test("Case queries are consistent") do
  lowercase = Pnn::Piece.new("k")
  uppercase = Pnn::Piece.new("K")

  raise "Lowercase should be lowercase" unless lowercase.lowercase?
  raise "Lowercase should not be uppercase" if lowercase.uppercase?
  raise "Case queries should be exclusive" if lowercase.lowercase? && lowercase.uppercase?

  raise "Uppercase should be uppercase" unless uppercase.uppercase?
  raise "Uppercase should not be lowercase" if uppercase.lowercase?
  raise "Case queries should be exclusive" if uppercase.lowercase? && uppercase.uppercase?
end

run_test("Object identity vs equality") do
  # Same content, different objects
  piece1 = Pnn::Piece.new("k", enhanced: true)
  piece2 = Pnn::Piece.new("k", enhanced: true)

  raise "Should be equal" unless piece1 == piece2
  raise "Should not be identical" if piece1.equal?(piece2)

  # Operations that return self
  piece3 = Pnn::Piece.new("k")
  bare_piece = piece3.bare

  raise "Should be identical" unless piece3.equal?(bare_piece)
  raise "Should be equal" unless piece3 == bare_piece
end

run_test("String conversion consistency") do
  piece = Pnn::Piece.new("k", enhanced: true, intermediate: true)

  # Multiple calls should return same string
  string1 = piece.to_s
  string2 = piece.to_s

  raise "Multiple to_s calls should be identical" unless string1.equal?(string2) || string1 == string2
  raise "String should be frozen" unless piece.letter.frozen?
  raise "String should not be frozen" if piece.to_s.frozen?
end

run_test("State manipulation order independence") do
  piece = Pnn::Piece.new("k")

  # Different orders should yield same result for commutative operations
  result1 = piece.enhance.intermediate
  result2 = piece.intermediate.enhance

  raise "Order should not matter for enhance+intermediate" unless result1 == result2

  # Flip should work regardless of other states
  complex = piece.enhance.intermediate
  flipped_first = piece.flip.enhance.intermediate
  flipped_last = complex.flip

  raise "Flip timing should not matter" unless flipped_first == flipped_last
end

# ============================================================================
# Performance and Memory Tests
# ============================================================================

run_test("Self-returning optimizations work") do
  piece = Pnn::Piece.new("k", enhanced: true)

  # These should return self
  same_enhance = piece.enhance
  raise "Should return self for no-op enhance" unless same_enhance.equal?(piece)

  simple_piece = Pnn::Piece.new("q")
  same_unenhance = simple_piece.unenhance
  raise "Should return self for no-op unenhance" unless same_unenhance.equal?(simple_piece)

  same_bare = simple_piece.bare
  raise "Should return self for no-op bare" unless same_bare.equal?(simple_piece)
end

run_test("No memory leaks in chaining") do
  # This test mainly verifies the code runs without infinite loops
  # or excessive object creation
  original = Pnn::Piece.new("k")

  # Long chain should complete successfully
  result = original
           .enhance.unenhance
           .diminish.undiminish
           .intermediate.unintermediate
           .flip.flip
           .bare

  raise "Long chain should return to original state" unless result == original
end

# ============================================================================
# Integration with Parse Tests
# ============================================================================

run_test("Parse creates equivalent objects to constructor") do
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

run_test("Constructor creates parseable strings") do
  # All possible combinations
  test_cases = [
    { letter: "k" },
    { letter: "K", enhanced: true },
    { letter: "p", diminished: true },
    { letter: "Q", intermediate: true },
    { letter: "r", enhanced: true, intermediate: true },
    { letter: "B", diminished: true, intermediate: true }
  ]

  test_cases.each do |params|
    letter = params.delete(:letter)
    piece = Pnn::Piece.new(letter, **params)
    pnn_string = piece.to_s
    reparsed = Pnn::Piece.parse(pnn_string)

    raise "Constructor->string->parse should yield equal piece for #{params}" unless piece == reparsed
  end
end

puts
puts "All Pnn::Piece tests passed!"
puts
