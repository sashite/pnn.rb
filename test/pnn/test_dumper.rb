# frozen_string_literal: true

require_relative "../../lib/pnn/dumper"

puts "Testing Pnn::Dumper..."

# --------------------------------------------------
# Test basic dumping with all parameters
# --------------------------------------------------
puts "Testing basic dumping with all parameters..."

# Simple letter with no modifiers
result = Pnn::Dumper.dump(letter: "k")
raise "Expected 'k', got '#{result}'" unless result == "k"

# Simple letter with prefix
result = Pnn::Dumper.dump(letter: "p", prefix: "+")
raise "Expected '+p', got '#{result}'" unless result == "+p"

# Simple letter with suffix
result = Pnn::Dumper.dump(letter: "q", suffix: "=")
raise "Expected 'q=', got '#{result}'" unless result == "q="

# Letter with both prefix and suffix
result = Pnn::Dumper.dump(letter: "r", prefix: "-", suffix: ">")
raise "Expected '-r>', got '#{result}'" unless result == "-r>"

# Uppercase letter
result = Pnn::Dumper.dump(letter: "K")
raise "Expected 'K', got '#{result}'" unless result == "K"

# Uppercase letter with modifiers
result = Pnn::Dumper.dump(letter: "R", prefix: "+", suffix: "<")
raise "Expected '+R<', got '#{result}'" unless result == "+R<"

# --------------------------------------------------
# Test with all valid modifiers
# --------------------------------------------------
puts "Testing with all valid modifiers..."

# Test all valid prefixes
["+", "-", nil].each do |prefix|
  result = Pnn::Dumper.dump(letter: "k", prefix: prefix)
  expected = prefix.nil? ? "k" : "#{prefix}k"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# Test all valid suffixes
["=", "<", ">", nil].each do |suffix|
  result = Pnn::Dumper.dump(letter: "k", suffix: suffix)
  expected = suffix.nil? ? "k" : "k#{suffix}"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# All possible combinations of valid prefixes and suffixes
[nil, "+", "-"].each do |prefix|
  [nil, "=", "<", ">"].each do |suffix|
    result = Pnn::Dumper.dump(letter: "k", prefix: prefix, suffix: suffix)
    expected = "#{prefix}k#{suffix}"
    raise "Expected '#{expected}', got '#{result}'" unless result == expected
  end
end

# --------------------------------------------------
# Test input validation
# --------------------------------------------------
puts "Testing input validation..."

# Invalid letters
["", "kp", "1", "*", " "].each do |invalid_letter|
  Pnn::Dumper.dump(letter: invalid_letter)
  raise "Expected ArgumentError for invalid letter: '#{invalid_letter}'"
rescue ArgumentError
  # Expected
end

# Invalid prefixes
["*", "++", "a", "1", " "].each do |invalid_prefix|
  Pnn::Dumper.dump(letter: "k", prefix: invalid_prefix)
  raise "Expected ArgumentError for invalid prefix: '#{invalid_prefix}'"
rescue ArgumentError
  # Expected
end

# Invalid suffixes
["*", "==", "a", "1", " "].each do |invalid_suffix|
  Pnn::Dumper.dump(letter: "k", suffix: invalid_suffix)
  raise "Expected ArgumentError for invalid suffix: '#{invalid_suffix}'"
rescue ArgumentError
  # Expected
end

# --------------------------------------------------
# Test with all valid letters
# --------------------------------------------------
puts "Testing with all valid letters..."

# All lowercase letters
("a".."z").each do |letter|
  result = Pnn::Dumper.dump(letter: letter)
  raise "Expected '#{letter}', got '#{result}'" unless result == letter
end

# All uppercase letters
("A".."Z").each do |letter|
  result = Pnn::Dumper.dump(letter: letter)
  raise "Expected '#{letter}', got '#{result}'" unless result == letter
end

# --------------------------------------------------
# Test edge cases
# --------------------------------------------------
puts "Testing edge cases..."

# Ensure that spaces in parameters are not allowed
begin
  Pnn::Dumper.dump(letter: " k")
  raise "Expected ArgumentError for letter with space"
rescue ArgumentError
  # Expected
end

begin
  Pnn::Dumper.dump(letter: "k ", prefix: "+")
  raise "Expected ArgumentError for letter with trailing space"
rescue ArgumentError
  # Expected
end

# Test when letter is nil
begin
  Pnn::Dumper.dump(letter: nil)
  raise "Expected ArgumentError for nil letter"
rescue ArgumentError
  # Expected
end

puts "✅ All Pnn::Dumper tests passed."
