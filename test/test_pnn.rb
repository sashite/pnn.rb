# frozen_string_literal: true

require_relative "../lib/pnn"

puts "Testing Pnn module..."

# --------------------------------------------------
# Test valid? method
# --------------------------------------------------
puts "Testing Pnn.valid?..."

# Basic letters
raise unless Pnn.valid?("k")
raise unless Pnn.valid?("K")
raise unless Pnn.valid?("p")

# With prefix
raise unless Pnn.valid?("+k")
raise unless Pnn.valid?("-p")

# With suffix
raise unless Pnn.valid?("k=")
raise unless Pnn.valid?("p<")
raise unless Pnn.valid?("q>")

# With both prefix and suffix
raise unless Pnn.valid?("+k=")
raise unless Pnn.valid?("-p<")
raise unless Pnn.valid?("+q>")

# Invalid cases
raise if Pnn.valid?("")
raise if Pnn.valid?("1")
raise if Pnn.valid?("!")
raise if Pnn.valid?("kp")
raise if Pnn.valid?("king")
raise if Pnn.valid?("*k")
raise if Pnn.valid?("++k")
raise if Pnn.valid?("k^")
raise if Pnn.valid?("k==")
raise if Pnn.valid?("+k=<")
raise if Pnn.valid?("+-k")

# All 26 lowercase letters
("a".."z").each do |letter|
  raise unless Pnn.valid?(letter)
end

# All 26 uppercase letters
("A".."Z").each do |letter|
  raise unless Pnn.valid?(letter)
end

# All valid combinations of prefixes and suffixes
[nil, "+", "-"].each do |prefix|
  [nil, "=", "<", ">"].each do |suffix|
    next if prefix.nil? && suffix.nil?

    pnn_string = "#{prefix}k#{suffix}"
    raise unless Pnn.valid?(pnn_string)
  end
end

# --------------------------------------------------
# Test parse method
# --------------------------------------------------
puts "Testing Pnn.parse..."

# Basic letter
result = Pnn.parse("k")
raise unless result == { letter: "k" }

# With prefix
result = Pnn.parse("+k")
raise unless result == { letter: "k", prefix: "+" }

# With suffix
result = Pnn.parse("k=")
raise unless result == { letter: "k", suffix: "=" }

# With both prefix and suffix
result = Pnn.parse("+k=")
raise unless result == { letter: "k", prefix: "+", suffix: "=" }

# Invalid strings should raise ArgumentError
begin
  Pnn.parse("")
  raise "Expected ArgumentError for empty string"
rescue ArgumentError
  # Expected
end

begin
  Pnn.parse("kp")
  raise "Expected ArgumentError for multiple letters"
rescue ArgumentError
  # Expected
end

begin
  Pnn.parse("1")
  raise "Expected ArgumentError for numeric character"
rescue ArgumentError
  # Expected
end

begin
  Pnn.parse("++k")
  raise "Expected ArgumentError for multiple prefixes"
rescue ArgumentError
  # Expected
end

# --------------------------------------------------
# Test safe_parse method
# --------------------------------------------------
puts "Testing Pnn.safe_parse..."

# Safe parse should return nil for invalid strings
raise unless Pnn.safe_parse("").nil?
raise unless Pnn.safe_parse("kp").nil?
raise unless Pnn.safe_parse("1").nil?
raise unless Pnn.safe_parse("++k").nil?

# Safe parse should work for valid strings
result = Pnn.safe_parse("k")
raise unless result == { letter: "k" }

result = Pnn.safe_parse("+k=")
raise unless result == { letter: "k", prefix: "+", suffix: "=" }

# --------------------------------------------------
# Test dump method
# --------------------------------------------------
puts "Testing Pnn.dump..."

# Basic piece
raise unless Pnn.dump(letter: "k") == "k"
raise unless Pnn.dump(letter: "K") == "K"

# With prefix
raise unless Pnn.dump(letter: "k", prefix: "+") == "+k"
raise unless Pnn.dump(letter: "K", prefix: "-") == "-K"

# With suffix
raise unless Pnn.dump(letter: "k", suffix: "=") == "k="
raise unless Pnn.dump(letter: "K", suffix: "<") == "K<"
raise unless Pnn.dump(letter: "p", suffix: ">") == "p>"

# With both prefix and suffix
raise unless Pnn.dump(letter: "k", prefix: "+", suffix: "=") == "+k="
raise unless Pnn.dump(letter: "K", prefix: "-", suffix: "<") == "-K<"
raise unless Pnn.dump(letter: "p", prefix: "+", suffix: ">") == "+p>"

# Invalid inputs should raise ArgumentError
begin
  Pnn.dump(letter: "")
  raise "Expected ArgumentError for empty letter"
rescue ArgumentError
  # Expected
end

begin
  Pnn.dump(letter: "kp")
  raise "Expected ArgumentError for multiple letters"
rescue ArgumentError
  # Expected
end

begin
  Pnn.dump(letter: "1")
  raise "Expected ArgumentError for numeric character"
rescue ArgumentError
  # Expected
end

begin
  Pnn.dump(letter: "k", prefix: "*")
  raise "Expected ArgumentError for invalid prefix"
rescue ArgumentError
  # Expected
end

begin
  Pnn.dump(letter: "k", suffix: "^")
  raise "Expected ArgumentError for invalid suffix"
rescue ArgumentError
  # Expected
end

# --------------------------------------------------
# Test string coercion
# --------------------------------------------------
puts "Testing string coercion..."

# Symbol should be coerced to string
raise unless Pnn.dump(letter: :k) == "k"
raise unless Pnn.parse(:k) == { letter: "k" }

# --------------------------------------------------
# Test roundtrip conversion
# --------------------------------------------------
puts "Testing roundtrip conversion..."

test_cases = [
  "k",
  "K",
  "+k",
  "-K",
  "p=",
  "q<",
  "r>",
  "+p=",
  "-q<",
  "+r>"
]

test_cases.each do |pnn_string|
  components = Pnn.parse(pnn_string)
  result = Pnn.dump(**components)
  raise "Round-trip conversion failed for #{pnn_string}" unless result == pnn_string
end

puts "✅ All Pnn tests passed."
