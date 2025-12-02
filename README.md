# Pnn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pnn.rb?label=Version&logo=github)](https://github.com/sashite/pnn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pnn.rb/main)
![Ruby](https://github.com/sashite/pnn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pnn.rb?label=License&logo=github)](https://github.com/sashite/pnn.rb/raw/main/LICENSE.md)

> **PNN** (Piece Name Notation) implementation for the Ruby language.

## What is PNN?

PNN (Piece Name Notation) is a formal, rule-agnostic naming system for identifying **pieces** in abstract strategy board games such as chess, shōgi, xiangqi, and their many variants. Each piece is represented by a canonical, human-readable ASCII name with optional state modifiers and optional terminal markers (e.g., `"KING"`, `"queen"`, `"+ROOK"`, `"-pawn"`, `"KING^"`).

This gem implements the [PNN Specification v1.0.0](https://sashite.dev/specs/pnn/1.0.0/), supporting validation, parsing, and comparison of piece names with integrated state management and terminal piece identification.

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
Sashite::Pnn.valid?("KING^")                  # => true (terminal piece)
Sashite::Pnn.valid?("+KING^")                 # => true (enhanced terminal piece)
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

### Terminal Markers
```ruby
# Terminal pieces (^ suffix)
terminal = Sashite::Pnn.parse("KING^")
terminal.terminal?                            # => true
terminal.base_name                            # => "KING"

# Non-terminal pieces (no suffix)
non_terminal = Sashite::Pnn.parse("PAWN")
non_terminal.terminal? # => false

# Combined state and terminal marker
enhanced_terminal = Sashite::Pnn.parse("+ROOK^")
enhanced_terminal.enhanced?                   # => true
enhanced_terminal.terminal?                   # => true
enhanced_terminal.base_name                   # => "ROOK"

diminished_terminal = Sashite::Pnn.parse("-king^")
diminished_terminal.diminished?               # => true
diminished_terminal.terminal?                 # => true
diminished_terminal.base_name                 # => "king"
```

### Player Assignment
```ruby
# First player pieces (uppercase)
first_player = Sashite::Pnn.parse("KING")
first_player.first_player?                    # => true
first_player.second_player?                   # => false

first_player_terminal = Sashite::Pnn.parse("KING^")
first_player_terminal.first_player?           # => true
first_player_terminal.terminal?               # => true

# Second player pieces (lowercase)
second_player = Sashite::Pnn.parse("king")
second_player.first_player?                   # => false
second_player.second_player?                  # => true

second_player_terminal = Sashite::Pnn.parse("king^")
second_player_terminal.second_player?         # => true
second_player_terminal.terminal?              # => true
```

### Normalization and Comparison
```ruby
a = Sashite::Pnn.parse("ROOK")
b = Sashite::Pnn.parse("ROOK")

a == b                                        # => true
a.same_base_name?(Sashite::Pnn.parse("rook")) # => true (same piece, different player)
a.same_base_name?(Sashite::Pnn.parse("ROOK^")) # => true (same piece, terminal marker)
a.same_base_name?(Sashite::Pnn.parse("+rook")) # => true (same piece, different state)
a.to_s # => "ROOK"
```

### Collections and Filtering
```ruby
pieces = %w[KING^ queen +ROOK -pawn BISHOP knight^ GENERAL^].map { |n| Sashite::Pnn.parse(n) }

# Filter by player
first_player_pieces = pieces.select(&:first_player?).map(&:to_s)
# => ["KING^", "+ROOK", "BISHOP", "GENERAL^"]

# Filter by state
enhanced_pieces = pieces.select(&:enhanced?).map(&:to_s)
# => ["+ROOK"]

diminished_pieces = pieces.select(&:diminished?).map(&:to_s)
# => ["-pawn"]

# Filter by terminal status
terminal_pieces = pieces.select(&:terminal?).map(&:to_s)
# => ["KING^", "knight^", "GENERAL^"]

# Combine filters
first_player_terminals = pieces.select { |p| p.first_player? && p.terminal? }.map(&:to_s)
# => ["KING^", "GENERAL^"]
```

## Format Specification

### Structure
```
[<state-modifier>]<piece-name>[<terminal-marker>]
```

Where:
- `<state-modifier>` is optional `+` (enhanced) or `-` (diminished)
- `<piece-name>` is case-consistent alphabetic characters
- `<terminal-marker>` is optional `^` (terminal piece)

### Grammar (BNF)
```bnf
<pnn> ::= <state-modifier> <name-body> <terminal-marker>
       | <state-modifier> <name-body>
       | <name-body> <terminal-marker>
       | <name-body>

<state-modifier> ::= "+" | "-"

<name-body> ::= <uppercase-name> | <lowercase-name>

<uppercase-name> ::= <uppercase-letter>+
<lowercase-name> ::= <lowercase-letter>+

<terminal-marker> ::= "^"

<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
```

### Regular Expression
```ruby
/\A[+-]?([A-Z]+|[a-z]+)\^?\z/
```

## Design Principles

* **Human-readable**: Names like `"KING"` or `"queen"` are intuitive and descriptive.
* **State-aware**: Integrated state management through `+` and `-` modifiers.
* **Terminal-aware**: Explicit identification of terminal pieces through `^` marker.
* **Rule-agnostic**: Independent of specific game mechanics.
* **Case-consistent**: Visual distinction between players through case.
* **Canonical**: One valid name per piece state within a given context.
* **ASCII-only**: Compatible with all systems.

## Integration with PIN

PNN names serve as the formal source for PIN character identifiers. For example:

| PNN        | PIN      | Description |
| ---------- | -------- | ----------- |
| `KING`     | `K`      | First player king |
| `king`     | `k`      | Second player king |
| `KING^`    | `K^`     | Terminal first player king |
| `king^`    | `k^`     | Terminal second player king |
| `+ROOK`    | `+R`     | Enhanced first player rook |
| `+ROOK^`   | `+R^`    | Enhanced terminal first player rook |
| `-pawn`    | `-p`     | Diminished second player pawn |
| `-pawn^`   | `-p^`    | Diminished terminal second player pawn |

Multiple PNN names may map to the same PIN character (e.g., `"KING"` and `"KHAN"` both → `K`), but PNN provides unambiguous naming within broader contexts.

## Examples
```ruby
# Traditional pieces
Sashite::Pnn.parse("KING")        # => #<Pnn::Name value="KING">
Sashite::Pnn.parse("queen")       # => #<Pnn::Name value="queen">

# Terminal pieces
Sashite::Pnn.parse("KING^")       # => #<Pnn::Name value="KING^">
Sashite::Pnn.parse("general^")    # => #<Pnn::Name value="general^">

# State modifiers
Sashite::Pnn.parse("+ROOK")       # => #<Pnn::Name value="+ROOK">
Sashite::Pnn.parse("-pawn")       # => #<Pnn::Name value="-pawn">

# Combined modifiers
Sashite::Pnn.parse("+KING^")      # => #<Pnn::Name value="+KING^">
Sashite::Pnn.parse("-pawn^")      # => #<Pnn::Name value="-pawn^">

# Validation
Sashite::Pnn.valid?("BISHOP")     # => true
Sashite::Pnn.valid?("KING^")      # => true
Sashite::Pnn.valid?("+ROOK^")     # => true
Sashite::Pnn.valid?("Bishop")     # => false (mixed case)
Sashite::Pnn.valid?("KING1")      # => false (no digits allowed)
Sashite::Pnn.valid?("^KING")      # => false (terminal marker must be suffix)
```

## API Reference

### Main Module

* `Sashite::Pnn.valid?(str)` — Returns `true` if the string is valid PNN.
* `Sashite::Pnn.parse(str)` — Returns a `Sashite::Pnn::Name` object.
* `Sashite::Pnn.name(sym_or_str)` — Alias for constructing a name.

### `Sashite::Pnn::Name`

* `#value` — Returns the canonical string value.
* `#to_s` — Returns the string representation.
* `#base_name` — Returns the name without state modifier or terminal marker.
* `#enhanced?` — Returns `true` if piece has enhanced state (`+` prefix).
* `#diminished?` — Returns `true` if piece has diminished state (`-` prefix).
* `#normal?` — Returns `true` if piece has normal state (no prefix).
* `#terminal?` — Returns `true` if piece is a terminal piece (`^` suffix).
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
