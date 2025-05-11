# frozen_string_literal: true

require_relative "../../lib/pnn/validator"

puts "Testing Pnn::Validator..."

# --------------------------------------------------
# Test basic validation
# --------------------------------------------------
puts "Testing basic validation..."

# Simple letters
raise unless Pnn::Validator.valid?("k")
raise unless Pnn::Validator.valid?("K")
raise unless Pnn::Validator.valid?("p")
raise unless Pnn::Validator.valid?("Z")

# With prefix
raise unless Pnn::Validator.valid?("+k")
raise unless Pnn::Validator.valid?("-p")
raise unless Pnn::Validator.valid?("+A")
raise unless Pnn::Validator.valid?("-Z")

# With suffix
raise unless Pnn::Validator.valid?("k=")
raise unless Pnn::Validator.valid?("p<")
raise unless Pnn::Validator.valid?("q>")
raise unless Pnn::Validator.valid?("Z=")
raise unless Pnn::Validator.valid?("A<")
raise unless Pnn::Validator.valid?("B>")

# With both prefix and suffix
raise unless Pnn::Validator.valid?("+k=")
raise unless Pnn::Validator.valid?("-p<")
raise unless Pnn::Validator.valid?("+q>")
raise unless Pnn::Validator.valid?("-Z=")
raise unless Pnn::Validator.valid?("+A<")
raise unless Pnn::Validator.valid?("-B>")

# --------------------------------------------------
# Test invalid strings
# --------------------------------------------------
puts "Testing invalid strings..."

# Empty string
raise if Pnn::Validator.valid?("")

# Non-letter characters
raise if Pnn::Validator.valid?("1")
raise if Pnn::Validator.valid?("!")
raise if Pnn::Validator.valid?("*")
raise if Pnn::Validator.valid?(" ")

# Multiple letters
raise if Pnn::Validator.valid?("kp")
raise if Pnn::Validator.valid?("king")
raise if Pnn::Validator.valid?("KING")

# Invalid prefixes
raise if Pnn::Validator.valid?("*k")
raise if Pnn::Validator.valid?("++k")
raise if Pnn::Validator.valid?("=k")
raise if Pnn::Validator.valid?("<k")
raise if Pnn::Validator.valid?(">k")

# Invalid suffixes
raise if Pnn::Validator.valid?("k*")
raise if Pnn::Validator.valid?("k==")
raise if Pnn::Validator.valid?("k+")
raise if Pnn::Validator.valid?("k-")

# Invalid combinations
raise if Pnn::Validator.valid?("+k=<")
raise if Pnn::Validator.valid?("+-k")
raise if Pnn::Validator.valid?("k=<")
raise if Pnn::Validator.valid?("++k=")
raise if Pnn::Validator.valid?("+k==")

# --------------------------------------------------
# Test all valid letters
# --------------------------------------------------
puts "Testing all valid letters..."

# All lowercase letters
("a".."z").each do |letter|
  raise unless Pnn::Validator.valid?(letter)
end

# All uppercase letters
("A".."Z").each do |letter|
  raise unless Pnn::Validator.valid?(letter)
end

# --------------------------------------------------
# Test all valid modifier combinations
# --------------------------------------------------
puts "Testing all valid modifier combinations..."

# Test every valid combination of prefixes and suffixes
[nil, "+", "-"].each do |prefix|
  [nil, "=", "<", ">"].each do |suffix|
    next if prefix.nil? && suffix.nil?

    pnn_string = "#{prefix}k#{suffix}"
    raise "Expected '#{pnn_string}' to be valid" unless Pnn::Validator.valid?(pnn_string)
  end
end

# --------------------------------------------------
# Test input type coercion
# --------------------------------------------------
puts "Testing input type coercion..."

# Symbol input
raise unless Pnn::Validator.valid?(:k)
raise unless Pnn::Validator.valid?(:"+k")
raise unless Pnn::Validator.valid?(:"-p<")
raise unless Pnn::Validator.valid?(:"+q>")

# --------------------------------------------------
# Test edge cases
# --------------------------------------------------
puts "Testing edge cases..."

# nil input
begin
  Pnn::Validator.valid?(nil)
  # Should not throw an error since method should handle it internally
rescue StandardError => e
  raise "Validator.valid? should handle nil input, got error: #{e.message}"
end

# Strings with spaces
raise if Pnn::Validator.valid?(" k")
raise if Pnn::Validator.valid?("k ")
raise if Pnn::Validator.valid?("+ k")
raise if Pnn::Validator.valid?("k =")

# Strings with newlines or tabs
raise if Pnn::Validator.valid?("\nk")
raise if Pnn::Validator.valid?("k\n")
raise if Pnn::Validator.valid?("\tk")
raise if Pnn::Validator.valid?("k\t")

puts "✅ All Pnn::Validator tests passed."
