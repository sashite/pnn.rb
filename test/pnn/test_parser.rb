# frozen_string_literal: true

require_relative "../../lib/pnn/parser"

puts "Testing Pnn::Parser..."

# --------------------------------------------------
# Test basic parsing
# --------------------------------------------------
puts "Testing basic parsing..."

# Simple letter with no modifiers
result = Pnn::Parser.parse("k")
raise "Expected {letter: 'k'}, got #{result}" unless result == { letter: "k" }

# Letter with prefix
result = Pnn::Parser.parse("+k")
raise "Expected {letter: 'k', prefix: '+'}, got #{result}" unless result == { letter: "k", prefix: "+" }

# Letter with suffix
result = Pnn::Parser.parse("k=")
raise "Expected {letter: 'k', suffix: '='}, got #{result}" unless result == { letter: "k", suffix: "=" }

# Letter with both prefix and suffix
result = Pnn::Parser.parse("+k=")
expected = { letter: "k", prefix: "+", suffix: "=" }
raise "Expected #{expected}, got #{result}" unless result == expected

# Uppercase letter
result = Pnn::Parser.parse("K")
raise "Expected {letter: 'K'}, got #{result}" unless result == { letter: "K" }

# Uppercase letter with modifiers
result = Pnn::Parser.parse("-K>")
expected = { letter: "K", prefix: "-", suffix: ">" }
raise "Expected #{expected}, got #{result}" unless result == expected

# --------------------------------------------------
# Test with all valid prefix and suffix combinations
# --------------------------------------------------
puts "Testing all valid prefix and suffix combinations..."

# All valid prefix options
["+", "-"].each do |prefix|
  result = Pnn::Parser.parse("#{prefix}k")
  expected = { letter: "k", prefix: prefix }
  raise "Expected #{expected}, got #{result}" unless result == expected
end

# All valid suffix options
["=", "<", ">"].each do |suffix|
  result = Pnn::Parser.parse("k#{suffix}")
  expected = { letter: "k", suffix: suffix }
  raise "Expected #{expected}, got #{result}" unless result == expected
end

# All combinations of prefixes and suffixes
["+", "-"].each do |prefix|
  ["=", "<", ">"].each do |suffix|
    result = Pnn::Parser.parse("#{prefix}k#{suffix}")
    expected = { letter: "k", prefix: prefix, suffix: suffix }
    raise "Expected #{expected}, got #{result}" unless result == expected
  end
end

# --------------------------------------------------
# Test with all valid letters
# --------------------------------------------------
puts "Testing with all valid letters..."

# All lowercase letters
("a".."z").each do |letter|
  result = Pnn::Parser.parse(letter)
  raise "Expected {letter: '#{letter}'}, got #{result}" unless result == { letter: letter }
end

# All uppercase letters
("A".."Z").each do |letter|
  result = Pnn::Parser.parse(letter)
  raise "Expected {letter: '#{letter}'}, got #{result}" unless result == { letter: letter }
end

# --------------------------------------------------
# Test invalid inputs
# --------------------------------------------------
puts "Testing invalid inputs..."

# Empty string
begin
  Pnn::Parser.parse("")
  raise "Expected ArgumentError for empty string"
rescue ArgumentError
  # Expected
end

# Multiple letters
begin
  Pnn::Parser.parse("kp")
  raise "Expected ArgumentError for multiple letters"
rescue ArgumentError
  # Expected
end

# Invalid characters
begin
  Pnn::Parser.parse("1")
  raise "Expected ArgumentError for numeric character"
rescue ArgumentError
  # Expected
end

begin
  Pnn::Parser.parse("*")
  raise "Expected ArgumentError for special character"
rescue ArgumentError
  # Expected
end

# Invalid prefix
begin
  Pnn::Parser.parse("*k")
  raise "Expected ArgumentError for invalid prefix"
rescue ArgumentError
  # Expected
end

begin
  Pnn::Parser.parse("++k")
  raise "Expected ArgumentError for multiple prefixes"
rescue ArgumentError
  # Expected
end

# Invalid suffix
begin
  Pnn::Parser.parse("k*")
  raise "Expected ArgumentError for invalid suffix"
rescue ArgumentError
  # Expected
end

begin
  Pnn::Parser.parse("k==")
  raise "Expected ArgumentError for multiple suffixes"
rescue ArgumentError
  # Expected
end

# Too many modifiers
begin
  Pnn::Parser.parse("+k=<")
  raise "Expected ArgumentError for too many modifiers"
rescue ArgumentError
  # Expected
end

begin
  Pnn::Parser.parse("+-k")
  raise "Expected ArgumentError for multiple prefixes"
rescue ArgumentError
  # Expected
end

# --------------------------------------------------
# Test non-string input coercion
# --------------------------------------------------
puts "Testing non-string input coercion..."

# Symbol input
result = Pnn::Parser.parse(:k)
raise "Expected {letter: 'k'}, got #{result}" unless result == { letter: "k" }

result = Pnn::Parser.parse(:"+k=")
expected = { letter: "k", prefix: "+", suffix: "=" }
raise "Expected #{expected}, got #{result}" unless result == expected

# --------------------------------------------------
# Test safe_parse
# --------------------------------------------------
puts "Testing safe_parse..."

# Valid inputs should return the same as parse
valid_inputs = ["k", "+k", "k=", "+k=", "K", "-K>"]
valid_inputs.each do |input|
  normal_result = Pnn::Parser.parse(input)
  safe_result = Pnn::Parser.safe_parse(input)
  raise "safe_parse inconsistent with parse for '#{input}'" unless normal_result == safe_result
end

# Invalid inputs should return nil instead of raising errors
invalid_inputs = ["", "kp", "1", "*k", "k*", "++k", "k==", "+k=<", "+-k"]
invalid_inputs.each do |input|
  result = Pnn::Parser.safe_parse(input)
  raise "Expected nil for invalid input '#{input}', got #{result}" unless result.nil?
end

# --------------------------------------------------
# Test edge cases
# --------------------------------------------------
puts "Testing edge cases..."

# nil input
begin
  Pnn::Parser.parse(nil)
  raise "Expected ArgumentError for nil input"
rescue ArgumentError
  # Expected
end

# Ensure nil from safe_parse for nil input
result = Pnn::Parser.safe_parse(nil)
raise "Expected nil for nil input, got #{result}" unless result.nil?

# Input with spaces
begin
  Pnn::Parser.parse(" k")
  raise "Expected ArgumentError for string with leading space"
rescue ArgumentError
  # Expected
end

begin
  Pnn::Parser.parse("k ")
  raise "Expected ArgumentError for string with trailing space"
rescue ArgumentError
  # Expected
end

begin
  Pnn::Parser.parse("+ k")
  raise "Expected ArgumentError for string with spaces"
rescue ArgumentError
  # Expected
end

puts "✅ All Pnn::Parser tests passed."
