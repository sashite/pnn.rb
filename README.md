# Snn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/snn.rb?label=Version&logo=github)](https://github.com/sashite/snn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/snn.rb/main)
![Ruby](https://github.com/sashite/snn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/snn.rb?label=License&logo=github)](https://github.com/sashite/snn.rb/raw/main/LICENSE.md)

> **SNN** (Style Name Notation) implementation for the Ruby language.

## What is SNN?

SNN (Style Name Notation) provides a rule-agnostic format for identifying styles in abstract strategy board games. SNN uses standardized naming conventions with case-based side encoding, enabling clear distinction between different traditions in multi-style gaming environments.

This gem implements the [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/), providing a modern Ruby interface with immutable style objects and functional programming principles.

## Installation

```ruby
# In your Gemfile
gem "sashite-snn"
```

Or install manually:

```sh
gem install sashite-snn
```

## Usage

```ruby
require "sashite/snn"

# Parse SNN strings into style objects
style = Sashite::Snn.parse("CHESS")         # => #<Snn::Style name=:Chess side=:first>
style.to_s                                  # => "CHESS"
style.name                                  # => :Chess
style.side                                  # => :first

# Create styles directly
style = Sashite::Snn.style(:Chess, :first)         # => #<Snn::Style name=:Chess side=:first>
style = Sashite::Snn::Style.new(:Shogi, :second)   # => #<Snn::Style name=:Shogi side=:second>

# Validate SNN strings
Sashite::Snn.valid?("CHESS")                # => true
Sashite::Snn.valid?("chess")                # => true
Sashite::Snn.valid?("Chess")                # => false (mixed case)
Sashite::Snn.valid?("123")                  # => false (must start with letter)

# Side manipulation (returns new immutable instances)
black_chess = style.flip                    # => #<Snn::Style name=:Chess side=:second>
black_chess.to_s                            # => "chess"

# Name manipulation
shogi_style = style.with_name(:Shogi)       # => #<Snn::Style name=:Shogi side=:first>
shogi_style.to_s                            # => "SHOGI"

# Side queries
style.first_player?                         # => true
black_chess.second_player?                  # => true

# Name and side comparison
chess1 = Sashite::Snn.parse("CHESS")
chess2 = Sashite::Snn.parse("chess")
shogi = Sashite::Snn.parse("SHOGI")

chess1.same_name?(chess2)                   # => true (both chess)
chess1.same_side?(shogi)                    # => true (both first player)
chess1.same_name?(shogi)                    # => false (different styles)

# Functional transformations can be chained
black_shogi = Sashite::Snn.parse("CHESS").with_name(:Shogi).flip
black_shogi.to_s                            # => "shogi"
```

## Format Specification

### Structure
```
<style-identifier>
```

### Components

- **Identifier**: Alphanumeric string starting with a letter
  - Uppercase: First player styles (`CHESS`, `SHOGI`, `XIANGQI`)
  - Lowercase: Second player styles (`chess`, `shogi`, `xiangqi`)
- **Case Consistency**: Entire identifier must be uppercase or lowercase (no mixed case)

### Regular Expression
```ruby
# Pattern accessible via Sashite::Snn::Style::SNN_PATTERN
/\A([A-Z][A-Z0-9]*|[a-z][a-z0-9]*)\z/
```

### Examples
- `CHESS` - First player chess style
- `chess` - Second player chess style
- `CHESS960` - First player Fischer Random Chess style
- `SHOGI` - First player shōgi style
- `shogi` - Second player shōgi style
- `XIANGQI` - First player xiangqi style

## Game Examples

### Classic Styles
```ruby
# Traditional game styles
chess = Sashite::Snn.style(:Chess, :first)        # => traditional chess
shogi = Sashite::Snn.style(:Shogi, :first)        # => traditional shōgi
xiangqi = Sashite::Snn.style(:Xiangqi, :first)    # => traditional xiangqi
makruk = Sashite::Snn.style(:Makruk, :first)      # => traditional makruk

# Player variations
white_chess = chess                               # => first player
black_chess = chess.flip                          # => second player
black_chess.to_s                                  # => "chess"
```

### Chess Variants
```ruby
# Fischer Random Chess
chess960_white = Sashite::Snn.style(:Chess960, :first)
chess960_black = chess960_white.flip
chess960_black.to_s                               # => "chess960"

# King of the Hill Chess
koth = Sashite::Snn.style(:Koth, :first)
koth.to_s                                         # => "KOTH"

# Three-Check Chess
threecheck = Sashite::Snn.style(:Threecheck, :first)
```

### Shōgi Variants
```ruby
# Traditional Shōgi
standard_shogi = Sashite::Snn.style(:Shogi, :first)

# Mini Shōgi
mini_shogi = Sashite::Snn.style(:Minishogi, :first)

# Chu Shōgi
chu_shogi = Sashite::Snn.style(:Chushogi, :first)
```

### Multi-Style Gaming
```ruby
# Cross-tradition match
def create_hybrid_match
  styles = [
    Sashite::Snn.style(:Chess, :first),     # White uses chess pieces
    Sashite::Snn.style(:Shogi, :second)     # Black uses shōgi pieces
  ]

  # Each player uses their preferred piece style
  styles
end

# Style compatibility check
def compatible_styles?(style1, style2)
  # Styles are compatible if they have different sides
  !style1.same_side?(style2)
end

chess_white = Sashite::Snn.parse("CHESS")
shogi_black = Sashite::Snn.parse("shogi")
puts compatible_styles?(chess_white, shogi_black)  # => true
```

## API Reference

### Main Module Methods

- `Sashite::Snn.valid?(snn_string)` - Check if string is valid SNN notation
- `Sashite::Snn.parse(snn_string)` - Parse SNN string into Style object
- `Sashite::Snn.style(name, side)` - Create style instance directly

### Style Class

#### Creation and Parsing
- `Sashite::Snn::Style.new(name, side)` - Create style instance
- `Sashite::Snn::Style.parse(snn_string)` - Parse SNN string (same as module method)

#### Attribute Access
- `#name` - Get style name (symbol with proper capitalization)
- `#side` - Get player side (:first or :second)
- `#to_s` - Convert to SNN string representation

#### Name and Case Handling

**Important**: The `name` attribute is always stored with proper capitalization (first letter uppercase, rest lowercase), regardless of the input case when parsing. The display case in `#to_s` is determined by the `side` attribute:

```ruby
# Both create the same internal name representation
style1 = Sashite::Snn.parse("CHESS")  # name: :Chess, side: :first
style2 = Sashite::Snn.parse("chess")  # name: :Chess, side: :second

style1.name    # => :Chess (proper capitalization)
style2.name    # => :Chess (same capitalization)

style1.to_s    # => "CHESS" (uppercase display)
style2.to_s    # => "chess" (lowercase display)
```

#### Side Queries
- `#first_player?` - Check if first player style
- `#second_player?` - Check if second player style

#### Transformations (immutable - return new instances)
- `#flip` - Switch player (change side)
- `#with_name(new_name)` - Create style with different name
- `#with_side(new_side)` - Create style with different side

#### Comparison Methods
- `#same_name?(other)` - Check if same style name
- `#same_side?(other)` - Check if same side
- `#==(other)` - Full equality comparison

### Style Class Constants

- `Sashite::Snn::Style::FIRST_PLAYER` - Symbol for first player (:first)
- `Sashite::Snn::Style::SECOND_PLAYER` - Symbol for second player (:second)
- `Sashite::Snn::Style::VALID_SIDES` - Array of valid sides
- `Sashite::Snn::Style::SNN_PATTERN` - Regular expression for SNN validation

## Advanced Usage

### Name Normalization Examples

```ruby
# Parsing different cases results in same name
white_chess = Sashite::Snn.parse("CHESS")
black_chess = Sashite::Snn.parse("chess")

# Names are normalized with proper capitalization
white_chess.name  # => :Chess
black_chess.name  # => :Chess (same name!)

# Sides are different
white_chess.side  # => :first
black_chess.side  # => :second

# Display follows side convention
white_chess.to_s  # => "CHESS"
black_chess.to_s  # => "chess"

# Same name, different sides
white_chess.same_name?(black_chess)  # => true
white_chess.same_side?(black_chess)  # => false
```

### Immutable Transformations
```ruby
# All transformations return new instances
original = Sashite::Snn.style(:Chess, :first)
flipped = original.flip
renamed = original.with_name(:Shogi)

# Original style is never modified
puts original.to_s  # => "CHESS"
puts flipped.to_s   # => "chess"
puts renamed.to_s   # => "SHOGI"

# Transformations can be chained
result = original.flip.with_name(:Xiangqi)
puts result.to_s    # => "xiangqi"
```

### Game Configuration Management
```ruby
class GameConfiguration
  def initialize
    @player_styles = {}
  end

  def set_player_style(player, style_name)
    side = player == :white ? :first : :second
    @player_styles[player] = Sashite::Snn.style(style_name, side)
  end

  def get_player_style(player)
    @player_styles[player]
  end

  def style_mismatch?
    return false if @player_styles.size < 2

    styles = @player_styles.values
    !styles.all? { |style| style.same_name?(styles.first) }
  end

  def cross_tradition_match?
    return false if @player_styles.size < 2

    style_names = @player_styles.values.map(&:name).uniq
    style_names.size > 1
  end
end

# Usage
config = GameConfiguration.new
config.set_player_style(:white, :Chess)
config.set_player_style(:black, :Shogi)

puts config.cross_tradition_match?  # => true
puts config.style_mismatch?         # => true

white_style = config.get_player_style(:white)
puts white_style.to_s               # => "CHESS"
```

### Style Analysis
```ruby
def analyze_styles(snns)
  styles = snns.map { |snn| Sashite::Snn.parse(snn) }

  {
    total: styles.size,
    by_side: styles.group_by(&:side),
    by_name: styles.group_by(&:name),
    unique_names: styles.map(&:name).uniq.size,
    cross_tradition: styles.map(&:name).uniq.size > 1
  }
end

snns = %w[CHESS chess SHOGI shogi XIANGQI xiangqi]
analysis = analyze_styles(snns)
puts analysis[:by_side][:first].size   # => 3
puts analysis[:unique_names]           # => 3
puts analysis[:cross_tradition]        # => true
```

### Tournament Style Management
```ruby
class TournamentStyleRegistry
  def initialize
    @registered_styles = Set.new
  end

  def register_style(style_name)
    # Register both sides of a style
    first_player_style = Sashite::Snn.style(style_name, :first)
    second_player_style = first_player_style.flip

    @registered_styles.add(first_player_style)
    @registered_styles.add(second_player_style)

    [first_player_style, second_player_style]
  end

  def valid_pairing?(style1, style2)
    @registered_styles.include?(style1) &&
    @registered_styles.include?(style2) &&
    !style1.same_side?(style2)
  end

  def available_styles_for_side(side)
    @registered_styles.select { |style| style.side == side }
  end

  def supported_traditions
    @registered_styles.map(&:name).uniq
  end
end

# Usage
registry = TournamentStyleRegistry.new
registry.register_style(:Chess)
registry.register_style(:Shogi)

chess_white = Sashite::Snn.parse("CHESS")
shogi_black = Sashite::Snn.parse("shogi")

puts registry.valid_pairing?(chess_white, shogi_black)  # => true
puts registry.supported_traditions                      # => [:Chess, :Shogi]
```

## Protocol Mapping

Following the [Game Protocol](https://sashite.dev/game-protocol/):

| Protocol Attribute | SNN Encoding | Examples | Notes |
|-------------------|--------------|----------|-------|
| **Style** | Alphanumeric identifier | `CHESS`, `SHOGI`, `XIANGQI` | Name is always stored with proper capitalization |
| **Side** | Case encoding | `CHESS` = First player, `chess` = Second player | Case is determined by side during rendering |

**Name Convention**: All style names are internally represented with proper capitalization (first letter uppercase, rest lowercase). The display case is determined by the `side` attribute: first player styles display as uppercase, second player styles as lowercase.

**Canonical principle**: Identical styles must have identical SNN representations.

## Properties

* **Rule-Agnostic**: Independent of specific game mechanics
* **Cross-Style Support**: Enables multi-tradition gaming environments
* **Canonical Representation**: Consistent naming for equivalent styles
* **Name Normalization**: Consistent proper capitalization representation internally
* **Immutable**: All style instances are frozen and transformations return new objects
* **Functional**: Pure functions with no side effects

## Implementation Notes

### Name Normalization Convention

SNN follows a strict name normalization convention:

1. **Internal Storage**: All style names are stored with proper capitalization (first letter uppercase, rest lowercase)
2. **Input Flexibility**: Both `"CHESS"` and `"chess"` are valid input during parsing
3. **Case Semantics**: Input case determines the `side` attribute, not the `name`
4. **Display Logic**: Output case is computed from `side` during rendering

This design ensures:
- Consistent internal representation regardless of input format
- Clear separation between style identity (name) and ownership (side)
- Predictable behavior when comparing styles of the same name

### Example Flow

```ruby
# Input: "chess" (lowercase)
# ↓ Parsing
# name: :Chess (normalized with proper capitalization)
# side: :second (inferred from lowercase input)
# ↓ Display
# SNN: "chess" (final representation)
```

This ensures that `parse(snn).to_s == snn` for all valid SNN strings while maintaining internal consistency.

## System Constraints

- **Alphanumeric identifiers** starting with a letter
- **Exactly 2 players** (uppercase/lowercase distinction)
- **Case consistency** within each identifier (no mixed case)

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) - Conceptual foundation for abstract strategy board games
- [PIN](https://sashite.dev/specs/pin/) - Piece Identifier Notation (ASCII piece representation)
- [PNN](https://sashite.dev/specs/pnn/) - Piece Name Notation (style-aware piece representation)
- [CELL](https://sashite.dev/specs/cell/) - Board position coordinates
- [HAND](https://sashite.dev/specs/hand/) - Reserve location notation
- [PMN](https://sashite.dev/specs/pmn/) - Portable Move Notation

## Documentation

- [Official SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/)
- [SNN Examples Documentation](https://sashite.dev/specs/snn/1.0.0/examples/)
- [Game Protocol Foundation](https://sashite.dev/game-protocol/)
- [API Documentation](https://rubydoc.info/github/sashite/snn.rb/main)

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/snn.rb.git
cd snn.rb

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
