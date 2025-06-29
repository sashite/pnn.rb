# Snn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/snn.rb?label=Version&logo=github)](https://github.com/sashite/snn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/snn.rb/main)
![Ruby](https://github.com/sashite/snn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/snn.rb?label=License&logo=github)](https://github.com/sashite/snn.rb/raw/main/LICENSE.md)

> **SNN** (Style Name Notation) support for the Ruby language.

## What is SNN?

SNN (Style Name Notation) is a rule-agnostic format for identifying piece styles in abstract strategy board games, as defined in the [Game Protocol](https://sashite.dev/game-protocol/). It provides unambiguous identification of piece styles using standardized naming conventions with case-based player assignment, enabling clear distinction between different piece traditions in multi-style gaming environments.

This gem implements the [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/), providing a Ruby interface for working with style identifiers through a clean and minimal API.

## Installation

```ruby
# In your Gemfile
gem "sashite-snn"
```

Or install manually:

```sh
gem install sashite-snn
```

## SNN Format

A SNN record consists of a style identifier that maps to the **Style attribute** from the [Game Protocol](https://sashite.dev/game-protocol/):

```
<style-identifier>
```

### Grammar Specification

```bnf
<snn> ::= <uppercase-style> | <lowercase-style>

<uppercase-style> ::= <letter-uppercase> <identifier-tail-uppercase>*
<lowercase-style> ::= <letter-lowercase> <identifier-tail-lowercase>*

<identifier-tail-uppercase> ::= <letter-uppercase> | <digit>
<identifier-tail-lowercase> ::= <letter-lowercase> | <digit>

<letter-uppercase> ::= "A" | "B" | "C" | ... | "Z"
<letter-lowercase> ::= "a" | "b" | "c" | ... | "z"
<digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```

### Protocol Mapping

SNN encodes style information with player association according to the Game Protocol:

| Protocol Attribute | SNN Encoding | Examples |
|-------------------|--------------|----------|
| **Style** | Alphanumeric identifier | `CHESS`, `SHOGI`, `XIANGQI` |
| **Player Association** | Case encoding | `CHESS` = First player, `chess` = Second player |

### Format Rules

- **Start character**: Must be alphabetic (`A-Z` for first player, `a-z` for second player)
- **Subsequent characters**: Alphabetic characters and digits only
- **Case consistency**: Entire identifier must be uppercase or lowercase (no mixed case)
- **Player assignment**: Uppercase = first player, lowercase = second player
- **Fixed assignment**: Player-style association remains constant throughout the match

## Basic Usage

### Creating Style Objects

The primary interface is the `Sashite::Snn::Style` class, which represents a style identifier in SNN format:

```ruby
require "sashite/snn"

# Parse a SNN string into a style object
style = Sashite::Snn::Style.parse("CHESS")
# => #<Sashite::Snn::Style:0x... @identifier="CHESS">

lowercase_style = Sashite::Snn::Style.parse("shogi")
# => #<Sashite::Snn::Style:0x... @identifier="shogi">

# Create directly with constructor
style = Sashite::Snn::Style.new("CHESS")
lowercase_style = Sashite::Snn::Style.new("makruk")

# Convenience method
style = Sashite::Snn.style("XIANGQI")
```

### Converting to String and Symbol

Convert a style object to different representations:

```ruby
style = Sashite::Snn::Style.parse("CHESS")
style.to_s   # => "CHESS"
style.to_sym # => :CHESS

variant_style = Sashite::Snn::Style.parse("chess960")
variant_style.to_s   # => "chess960"
variant_style.to_sym # => :chess960

# Useful for hash keys and case statements
game_config = {
  style.to_sym => { pieces: chess_pieces, rules: chess_rules }
}

case style.to_sym
when :CHESS then setup_chess_game
when :SHOGI then setup_shogi_game
end
```

### Player Association

Check which player a style belongs to according to the Game Protocol:

```ruby
first_player_style = Sashite::Snn::Style.parse("CHESS")
first_player_style.first_player?  # => true (uppercase = first player)
first_player_style.second_player? # => false

second_player_style = Sashite::Snn::Style.parse("shogi")
second_player_style.first_player?  # => false
second_player_style.second_player? # => true (lowercase = second player)
```

## Validation

All parsing automatically validates input according to the SNN specification:

```ruby
# Valid SNN strings
Sashite::Snn::Style.parse("CHESS")      # ✓ First player chess
Sashite::Snn::Style.parse("shogi")      # ✓ Second player shogi
Sashite::Snn::Style.parse("CHESS960")   # ✓ First player Chess960 variant
Sashite::Snn::Style.parse("makruk")     # ✓ Second player makruk

# Valid constructor calls
Sashite::Snn::Style.new("XIANGQI")      # ✓ First player xiangqi
Sashite::Snn::Style.new("janggi")       # ✓ Second player janggi

# Convenience method
Sashite::Snn.style("MINISHOGI") # ✓ First player minishogi

# Check validity
Sashite::Snn.valid?("CHESS")    # => true
Sashite::Snn.valid?("Chess")    # => false (mixed case not allowed)
Sashite::Snn.valid?("123")      # => false (must start with letter)
Sashite::Snn.valid?("")         # => false (empty string)

# Invalid SNN strings raise ArgumentError
Sashite::Snn::Style.parse("")           # ✗ ArgumentError
Sashite::Snn::Style.parse("Chess")      # ✗ ArgumentError (mixed case)
Sashite::Snn::Style.parse("9CHESS")     # ✗ ArgumentError (starts with digit)
Sashite::Snn::Style.parse("CHESS-960")  # ✗ ArgumentError (contains hyphen)
```

## Examples of SNN in Practice

### Classic Game Styles

```ruby
# Traditional chess match (both players use chess pieces)
first_player = Sashite::Snn::Style.parse("CHESS")   # First player
second_player = Sashite::Snn::Style.parse("chess")  # Second player

# Cross-style game: Chess vs Shogi
first_player = Sashite::Snn::Style.parse("CHESS")   # First player uses chess pieces
second_player = Sashite::Snn::Style.parse("shogi")  # Second player uses shogi pieces

# Variant games
first_player = Sashite::Snn::Style.parse("CHESS960") # First player uses Chess960 variant
second_player = Sashite::Snn::Style.parse("chess960") # Second player uses Chess960 variant
```

### Style Examples from SNN Specification

According to the [SNN Examples Documentation](https://sashite.dev/specs/snn/1.0.0/examples/):

| SNN | Interpretation |
|-----|----------------|
| `CHESS` | Chess first player (white) |
| `chess` | Chess second player (black) |
| `SHOGI` | Shōgi first player (sente) |
| `shogi` | Shōgi second player (gote) |
| `XIANGQI` | Xiangqi first player (red) |
| `xiangqi` | Xiangqi second player (black) |

```ruby
# Standard game representations
chess_white = Sashite::Snn::Style.parse("CHESS")    # White pieces (first player)
chess_black = Sashite::Snn::Style.parse("chess")    # Black pieces (second player)

shogi_sente = Sashite::Snn::Style.parse("SHOGI")    # Sente (first player)
shogi_gote = Sashite::Snn::Style.parse("shogi")     # Gote (second player)

xiangqi_red = Sashite::Snn::Style.parse("XIANGQI")  # Red pieces (first player)
xiangqi_black = Sashite::Snn::Style.parse("xiangqi") # Black pieces (second player)
```

### Variant Styles

```ruby
# Chess variants
fischer_random = Sashite::Snn::Style.parse("CHESS960")
king_of_hill = Sashite::Snn::Style.parse("CHESSKING")

# Shogi variants
mini_shogi = Sashite::Snn::Style.parse("MINISHOGI")
handicap_shogi = Sashite::Snn::Style.parse("SHOGI9")

# Other traditions
thai_makruk = Sashite::Snn::Style.parse("MAKRUK")
korean_janggi = Sashite::Snn::Style.parse("JANGGI")
```

### Cross-Style Gaming

```ruby
# Create a cross-style game setup
first_player_style = Sashite::Snn::Style.parse("CHESS")
second_player_style = Sashite::Snn::Style.parse("makruk")

puts "Game: #{first_player_style} vs #{second_player_style}"
# => "Game: CHESS vs makruk"

# This represents a unique game where chess pieces face makruk pieces

# Each player keeps their assigned style throughout the game
game_config = {
  first_player:  first_player_style, # Fixed: CHESS
  second_player: second_player_style # Fixed: makruk
}

# Using symbols for configuration
style_configs = {
  first_player_style.to_sym  => { piece_set: :western, board: :"8x8" },
  second_player_style.to_sym => { piece_set: :thai, board: :"8x8" }
}
```

## API Reference

### Module Methods

- `Sashite::Snn.valid?(snn_string)` - Check if a string is valid SNN notation
- `Sashite::Snn.style(identifier)` - Convenience method to create style objects

### Sashite::Snn::Style Class Methods

- `Sashite::Snn::Style.parse(snn_string)` - Parse a SNN string into a style object
- `Sashite::Snn::Style.new(identifier)` - Create a new style instance

### Instance Methods

#### Player Queries
- `#first_player?` - Check if style belongs to first player (uppercase)
- `#second_player?` - Check if style belongs to second player (lowercase)
- `#uppercase?` - Check if identifier is uppercase
- `#lowercase?` - Check if identifier is lowercase

#### Conversion
- `#to_s` - Convert to SNN string representation
- `#to_sym` - Convert to symbol representation
- `#inspect` - Detailed string representation for debugging

## Design Properties

Following the SNN specification, this implementation provides:

- **Rule-agnostic**: Independent of specific game mechanics
- **Unambiguous identification**: Clear distinction between different piece traditions
- **Cross-style support**: Enables multi-tradition gaming environments
- **Canonical representation**: Consistent naming for equivalent styles
- **Player clarity**: Case-based player association throughout gameplay

## System Constraints

* SNN supports exactly **two players**
* Players are distinguished by casing: **uppercase** for first player, **lowercase** for second player
* Style identifiers must start with an alphabetic character
* Subsequent characters may include alphabetic characters and digits only
* Mixed casing is not permitted within a single identifier
* Style assignment to players remains **fixed throughout a game**
* Total piece count must remain constant (Game Protocol conservation principle)

## Use Cases

SNN is particularly useful in the following scenarios:

1. **Multi-style environments**: When games involve pieces from multiple traditions or variants
2. **Game engine development**: When implementing engines that need to distinguish between different piece style traditions
3. **Hybrid games**: When creating or analyzing games that combine elements from different piece traditions
4. **Database systems**: When storing game data that must avoid naming conflicts between similar styles
5. **Cross-tradition analysis**: When comparing or analyzing strategic elements across different piece traditions
6. **Tournament systems**: When organizing events that allow players to choose from different piece style traditions

## Game Protocol Compliance

This implementation fully complies with the [Game Protocol](https://sashite.dev/game-protocol/) by:

- Representing the **Style attribute** of pieces
- Supporting **two-player** constraint
- Maintaining **piece conservation** (styles are immutable)
- Enabling **cross-style** gameplay scenarios
- Providing **deterministic** style identification

## Documentation

- [Official SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/)
- [SNN Examples Documentation](https://sashite.dev/specs/snn/1.0.0/examples/)
- [Game Protocol Foundation](https://sashite.dev/game-protocol/)
- [API Documentation](https://rubydoc.info/github/sashite/snn.rb/main)

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
