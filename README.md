# Pnn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pnn.rb?label=Version&logo=github)](https://github.com/sashite/pnn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pnn.rb/main)
![Ruby](https://github.com/sashite/pnn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pnn.rb?label=License&logo=github)](https://github.com/sashite/pnn.rb/raw/main/LICENSE.md)

> **PNN** (Piece Name Notation) implementation for the Ruby language.

## What is PNN?

PNN (Piece Name Notation) is a formal, rule-agnostic naming system for identifying **pieces** in abstract strategy board games such as chess, shÅgi, xiangqi, and their many variants. Each piece is represented by a canonical, human-readable ASCII name with optional state modifiers (e.g., `"KING"`, `"queen"`, `"+ROOK"`, `"-pawn"`).

This gem implements the [PNN Specification v1.0.0](https://sashite.dev/specs/pnn/1.0.0/), supporting validation, parsing, and comparison of piece names with integrated state management.

## Installation

```ruby
# In your Gemfile
gem "sashite-pnn"
```

Or install manually:

```sh
gem install sashite-pnn
```

## Usage

### Basic Operations

```ruby
require "sashite/pnn"

# Parse PNN strings into piece name objects
name = Sashite::Pnn.parse("KING")             # => #<Pnn::Name value="KING">
name.to_s                                     # => "KING"
name.value                                    # => "KING"

# Create from string or symbol
name = Sashite::Pnn.name("queen")             # => #<Pnn::Name value="queen">
name = Sashite::Pnn::Name.new(:ROOK)          # => #<Pnn::Name value="ROOK">

# Validate PNN strings
Sashite::Pnn.valid?("BISHOP")                 # => true
Sashite::Pnn.valid?("King")                   # => false (mixed case not allowed)
Sashite::Pnn.valid?("+ROOK")                  # => true (enhanced state)
Sashite::Pnn.valid?("-pawn")                  # => true (diminished state)
```

### State Modifiers

```ruby
# Enhanced pieces (+ prefix)
enhanced = Sashite::Pnn.parse("+QUEEN")
enhanced.enhanced?                            # => true
enhanced.normal?                              # => false
enhanced.base_name                            # => "QUEEN"

# Diminished pieces (- prefix)
diminished = Sashite::Pnn.parse("-pawn")
diminished.diminished?                        # => true
diminished.base_name                          # => "pawn"

# Normal pieces (no prefix)
normal = Sashite::Pnn.parse("KNIGHT")
normal.normal?                                # => true
normal.enhanced?                              # => false
normal.diminished?                            # => false
```

### Player Assignment

```ruby
# First player pieces (uppercase)
first_player = Sashite::Pnn.parse("KING")
first_player.first_player?                    # => true
first_player.second_player?                   # => false

# Second player pieces (lowercase)
second_player = Sashite::Pnn.parse("king")
second_player.first_player?                   # => false
second_player.second_player?                  # => true
```

### Normalization and Comparison

```ruby
a = Sashite::Pnn.parse("ROOK")
b = Sashite::Pnn.parse("ROOK")

a == b                                        # => true
a.same_base_name?(Sashite::Pnn.parse("rook")) # => true (same piece, different player)
a.to_s                                        # => "ROOK"
```

### Collections and Filtering

```ruby
pieces = %w[KING queen +ROOK -pawn BISHOP knight].map { |n| Sashite::Pnn.parse(n) }

# Filter by player
first_player_pieces = pieces.select(&:first_player?).map(&:to_s)
# => ["KING", "+ROOK", "BISHOP"]

# Filter by state
enhanced_pieces = pieces.select(&:enhanced?).map(&:to_s)
# => ["+ROOK"]

diminished_pieces = pieces.select(&:diminished?).map(&:to_s)
# => ["-pawn"]
```

## Format Specification

### Structure

```
<state-modifier>?<piece-name>
```

Where:
- `<state-modifier>` is optional `+` (enhanced) or `-` (diminished)
- `<piece-name>` is case-consistent alphabetic characters

### Grammar (BNF)

```bnf
<pnn> ::= <state-modifier> <name-body>
       | <name-body>

<state-modifier> ::= "+" | "-"

<name-body> ::= <uppercase-name> | <lowercase-name>

<uppercase-name> ::= <uppercase-letter>+
<lowercase-name> ::= <lowercase-letter>+

<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
```

### Regular Expression

```ruby
/\A[+-]?([A-Z]+|[a-z]+)\z/
```

## Design Principles

* **Human-readable**: Names like `"KING"` or `"queen"` are intuitive and descriptive.
* **State-aware**: Integrated state management through `+` and `-` modifiers.
* **Rule-agnostic**: Independent of specific game mechanics.
* **Case-consistent**: Visual distinction between players through case.
* **Canonical**: One valid name per piece state within a given context.
* **ASCII-only**: Compatible with all systems.

## Integration with PIN

PNN names serve as the formal source for PIN character identifiers. For example:

| PNN       | PIN     | Description |
| --------- | ------- | ----------- |
| `KING`    | `K`     | First player king |
| `king`    | `k`     | Second player king |
| `+ROOK`   | `+R`    | Enhanced first player rook |
| `-pawn`   | `-p`    | Diminished second player pawn |

Multiple PNN names may map to the same PIN character (e.g., `"KING"` and `"KHAN"` both â†' `K`), but PNN provides unambiguous naming within broader contexts.

## Examples

```ruby
# Traditional pieces
Sashite::Pnn.parse("KING")        # => #<Pnn::Name value="KING">
Sashite::Pnn.parse("queen")       # => #<Pnn::Name value="queen">

# State modifiers
Sashite::Pnn.parse("+ROOK")       # => #<Pnn::Name value="+ROOK">
Sashite::Pnn.parse("-pawn")       # => #<Pnn::Name value="-pawn">

# Validation
Sashite::Pnn.valid?("BISHOP")     # => true
Sashite::Pnn.valid?("Bishop")     # => false (mixed case)
Sashite::Pnn.valid?("KING1")      # => false (no digits allowed)
```

## API Reference

### Main Module

* `Sashite::Pnn.valid?(str)` — Returns `true` if the string is valid PNN.
* `Sashite::Pnn.parse(str)` — Returns a `Sashite::Pnn::Name` object.
* `Sashite::Pnn.name(sym_or_str)` — Alias for constructing a name.

### `Sashite::Pnn::Name`

* `#value` — Returns the canonical string value.
* `#to_s` — Returns the string representation.
* `#base_name` — Returns the name without state modifier.
* `#enhanced?` — Returns `true` if piece has enhanced state (`+` prefix).
* `#diminished?` — Returns `true` if piece has diminished state (`-` prefix).
* `#normal?` — Returns `true` if piece has normal state (no prefix).
* `#first_player?` — Returns `true` if piece belongs to first player (uppercase).
* `#second_player?` — Returns `true` if piece belongs to second player (lowercase).
* `#same_base_name?(other)` — Returns `true` if both pieces have same base name.
* `#==`, `#eql?`, `#hash` — Value-based equality.

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/pnn.rb.git
cd pnn.rb

# Install dependencies
bundle install

# Run tests
ruby test.rb

# Generate documentation
yard doc
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Add tests for your changes
4. Ensure all tests pass (`ruby test.rb`)
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
