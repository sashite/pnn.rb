# Snn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/snn.rb?label=Version&logo=github)](https://github.com/sashite/snn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/snn.rb/main)
![Ruby](https://github.com/sashite/snn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/snn.rb?label=License&logo=github)](https://github.com/sashite/snn.rb/raw/main/LICENSE.md)

> **SNN** (Style Name Notation) support for the Ruby language.

## What is SNN?

SNN (Style Name Notation) is a consistent and rule-agnostic format for identifying piece styles in abstract strategy board games. It provides unambiguous identification of piece styles by using standardized naming conventions, enabling clear distinction between different piece traditions, variants, or design approaches within multi-style gaming environments.

This gem implements the [SNN Specification v1.0.0](https://sashite.dev/documents/snn/1.0.0/), providing a Ruby interface for working with style identifiers through a clean and minimal API.

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

A SNN record consists of an identifier starting with an alphabetic character, followed by optional alphabetic characters and digits:

```
<style-id>
```

Where:
- The identifier starts with an alphabetic character (`A-Z` for uppercase, `a-z` for lowercase)
- Subsequent characters may include alphabetic characters and digits (`A-Z`, `0-9` for uppercase styles; `a-z`, `0-9` for lowercase styles)
- **Uppercase** format denotes styles belonging to the first player
- **Lowercase** format denotes styles belonging to the second player
- The entire identifier must be entirely uppercase or entirely lowercase

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

Check which player a style belongs to:

```ruby
first_player_style = Sashite::Snn::Style.parse("CHESS")
first_player_style.first_player?  # => true
first_player_style.second_player? # => false

second_player_style = Sashite::Snn::Style.parse("shogi")
second_player_style.first_player?  # => false
second_player_style.second_player? # => true
```

## Validation

All parsing automatically validates input according to the SNN specification:

```ruby
# Valid SNN strings
Sashite::Snn::Style.parse("CHESS")      # ✓
Sashite::Snn::Style.parse("shogi")      # ✓
Sashite::Snn::Style.parse("CHESS960")   # ✓
Sashite::Snn::Style.parse("makruk")     # ✓

# Valid constructor calls
Sashite::Snn::Style.new("XIANGQI")      # ✓
Sashite::Snn::Style.new("janggi")       # ✓

# Convenience method
Sashite::Snn.style("MINISHOGI") # ✓

# Check validity
Sashite::Snn.valid?("CHESS")    # => true
Sashite::Snn.valid?("Chess")    # => false (mixed case)
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
# International Chess
first_player = Sashite::Snn::Style.parse("CHESS")   # First player uses chess pieces
second_player = Sashite::Snn::Style.parse("chess")  # Second player uses chess pieces

# Cross-style game: Chess vs Shogi
first_player = Sashite::Snn::Style.parse("CHESS")   # First player uses chess pieces
second_player = Sashite::Snn::Style.parse("shogi")  # Second player uses shogi pieces

# Variant games
first_player = Sashite::Snn::Style.parse("CHESS960") # First player uses Chess960 variant
second_player = Sashite::Snn::Style.parse("chess960") # Second player uses Chess960 variant
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
- `#uppercase?` - Alias for `#first_player?`
- `#lowercase?` - Alias for `#second_player?`

#### Conversion
- `#to_s` - Convert to SNN string representation
- `#to_sym` - Convert to symbol representation
- `#inspect` - Detailed string representation for debugging

## Properties of SNN

* **Rule-agnostic**: SNN does not encode game states, legality, validity, or game-specific conditions
* **Unambiguous identification**: Different piece styles can coexist without naming conflicts
* **Canonical representation**: Equivalent styles yield identical strings
* **Cross-style support**: Enables games where players use different piece traditions
* **Case consistency**: Each identifier is entirely uppercase or entirely lowercase
* **Fixed assignment**: Style assignment to players remains constant throughout a game

## Constraints

* SNN supports exactly **two players**
* Players are distinguished by casing: **uppercase** for first player, **lowercase** for second player
* Style identifiers must start with an alphabetic character
* Subsequent characters may include alphabetic characters and digits
* Mixed casing is not permitted within a single identifier
* Style assignment to players remains **fixed throughout a game**

## Use Cases

SNN is particularly useful in the following scenarios:

1. **Multi-style environments**: When games involve pieces from multiple traditions or variants
2. **Game engine development**: When implementing engines that need to distinguish between different piece style traditions
3. **Hybrid games**: When creating or analyzing games that combine elements from different piece traditions
4. **Database systems**: When storing game data that must avoid naming conflicts between similar styles
5. **Cross-tradition analysis**: When comparing or analyzing strategic elements across different piece traditions
6. **Tournament systems**: When organizing events that allow players to choose from different piece style traditions

## Documentation

- [Official SNN Specification](https://sashite.dev/documents/snn/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/snn.rb/main)

## License

The [gem](https://rubygems.org/gems/sashite-snn) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
