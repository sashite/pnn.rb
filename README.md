# Pnn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pnn.rb?label=Version&logo=github)](https://github.com/sashite/pnn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pnn.rb/main)
![Ruby](https://github.com/sashite/pnn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pnn.rb?label=License&logo=github)](https://github.com/sashite/pnn.rb/raw/main/LICENSE.md)

> **PNN** (Piece Name Notation) support for the Ruby language.

## What is PNN?

PNN (Piece Name Notation) extends [PIN (Piece Identifier Notation)](https://sashite.dev/specs/pin/1.0.0/) to provide style-aware piece representation in abstract strategy board games. It adds a derivation marker that distinguishes pieces by their style origin, enabling cross-style game scenarios and piece origin tracking.

This gem implements the [PNN Specification v1.0.0](https://sashite.dev/specs/pnn/1.0.0/), providing a Ruby interface for working with style-aware piece representations through an intuitive object-oriented API.

## Installation

```ruby
# In your Gemfile
gem "sashite-pnn"
```

Or install manually:

```sh
gem install sashite-pnn
```

## PNN Format

A PNN record consists of a [PIN](https://sashite.dev/specs/pin/1.0.0/) string with an optional derivation suffix:

```
<pin>[<suffix>]
```

Where:
- `<pin>` is a valid PIN string (`[<state>]<letter>`)
- `<suffix>` is an optional derivation marker (`'` for foreign style)

Examples:
- `K` - First player king with native style
- `K'` - First player king with foreign style
- `+R` - First player rook with enhanced state and native style
- `+R'` - First player rook with enhanced state and foreign style

## Basic Usage

### Creating Piece Objects

The primary interface is the `Sashite::Pnn::Piece` class, which represents a single piece in PNN format:

```ruby
require "sashite/pnn"

# Parse a PNN string into a piece object
piece = Sashite::Pnn::Piece.parse("k")
# => #<Sashite::Pnn::Piece letter="k" native=true>

# With derivation marker
foreign_piece = Sashite::Pnn::Piece.parse("k'")
# => #<Sashite::Pnn::Piece letter="k" native=false>

# With state modifiers and derivation
enhanced_foreign = Sashite::Pnn::Piece.parse("+k'")
# => #<Sashite::Pnn::Piece letter="k" enhanced=true native=false>

# Create directly with constructor
piece = Sashite::Pnn::Piece.new("k")
foreign_piece = Sashite::Pnn::Piece.new("k", native: false)
enhanced_piece = Sashite::Pnn::Piece.new("k", enhanced: true, native: false)
```

### Converting to PNN String

Convert a piece object back to its PNN string representation:

```ruby
piece = Sashite::Pnn::Piece.parse("k")
piece.to_s
# => "k"

foreign_piece = Sashite::Pnn::Piece.parse("k'")
foreign_piece.to_s
# => "k'"

enhanced_foreign = Sashite::Pnn::Piece.parse("+k'")
enhanced_foreign.to_s
# => "+k'"
```

### Style Manipulation

Create new piece instances with different styles:

```ruby
piece = Sashite::Pnn::Piece.parse("k")

# Convert to foreign style
foreign = piece.foreignize
foreign.to_s # => "k'"

# Convert to native style
native = foreign.nativize
native.to_s # => "k"

# Toggle style
toggled = piece.toggle_style
toggled.to_s # => "k'"
```

### State Manipulation (inherited from PIN)

All PIN state manipulation methods are available:

```ruby
piece = Sashite::Pnn::Piece.parse("k")

# Enhanced state (+ prefix)
enhanced = piece.enhance
enhanced.to_s # => "+k"

# Diminished state (- prefix)
diminished = piece.diminish
diminished.to_s # => "-k"

# Combine with style changes
enhanced_foreign = piece.enhance.foreignize
enhanced_foreign.to_s # => "+k'"
```

### Ownership Changes

Change piece ownership (case conversion):

```ruby
white_king = Sashite::Pnn::Piece.parse("K")
black_king = white_king.flip
black_king.to_s # => "k"

# Works with foreign pieces too
foreign_white = Sashite::Pnn::Piece.parse("K'")
foreign_black = foreign_white.flip
foreign_black.to_s # => "k'"
```

## Cross-Style Game Examples

### Chess vs. Shōgi Match

In a hybrid game where the first player uses Chess pieces and the second player uses Shōgi pieces:

```ruby
# First player (Chess style is native)
white_pawn = Sashite::Pnn::Piece.parse("P") # Chess pawn (native)
white_shogi_pawn = Sashite::Pnn::Piece.parse("P'") # Shōgi pawn (foreign)

# Second player (Shōgi style is native)
black_pawn = Sashite::Pnn::Piece.parse("p") # Shōgi pawn (native)
black_chess_pawn = Sashite::Pnn::Piece.parse("p'") # Chess pawn (foreign)

# Promoted pieces with style
promoted_shogi = Sashite::Pnn::Piece.parse("+P'") # Promoted Shōgi pawn (foreign to first player)
```

### Style Conversions During Gameplay

```ruby
# Capture and style conversion
enemy_piece = Sashite::Pnn::Piece.parse("p'")  # Enemy's foreign piece
captured = enemy_piece.flip.nativize           # Convert to our side with native style
captured.to_s # => "P"

# Promotion with style preservation
pawn = Sashite::Pnn::Piece.parse("p'")         # Foreign pawn
promoted = pawn.enhance                        # Promote while keeping foreign style
promoted.to_s # => "+p'"
```

## Style Logic

### Native vs Foreign Style

- **No suffix**: Piece has the **native style** of its current side
- **Apostrophe suffix (`'`)**: Piece has the **foreign style** (opposite side's native style)

### Style Assignment

```ruby
piece = Sashite::Pnn::Piece.parse("K")

# Check style
piece.native?    # => true
piece.foreign?   # => false

# Convert styles
foreign = piece.foreignize
foreign.native?  # => false
foreign.foreign? # => true

native = foreign.nativize
native.native?   # => true
native.foreign?  # => false
```

## State Modifier Methods

The `Sashite::Pnn::Piece` class inherits all PIN functionality and adds style methods:

### Inherited from PIN
| Method | Description | Example |
|--------|-------------|---------|
| `enhance` | Add Enhanced state (`+` prefix) | `k` → `+k` |
| `unenhance` | Remove Enhanced state | `+k` → `k` |
| `diminish` | Add Diminished state (`-` prefix) | `k` → `-k` |
| `undiminish` | Remove Diminished state | `-k` → `k` |
| `normalize` | Remove all state modifiers | `+k` → `k` |
| `flip` | Change ownership (case) | `K` → `k`, `k` → `K` |

### PNN-Specific Style Methods
| Method | Description | Example |
|--------|-------------|---------|
| `foreignize` | Convert to foreign style | `k` → `k'` |
| `nativize` | Convert to native style | `k'` → `k` |
| `toggle_style` | Toggle between native/foreign | `k` → `k'`, `k'` → `k` |

All methods return new `Sashite::Pnn::Piece` instances, leaving the original unchanged (immutable design).

## API Reference

### Module Methods

- `Sashite::Pnn.valid?(pnn_string)` - Check if a string is valid PNN notation
- `Sashite::Pnn.parse(pnn_string)` - Parse a PNN string into a piece object

### Sashite::Pnn::Piece Class Methods

- `Sashite::Pnn::Piece.parse(pnn_string)` - Parse a PNN string into a piece object
- `Sashite::Pnn::Piece.new(letter, **options)` - Create a new piece instance

### Instance Methods

#### Style Queries
- `#native?` - Check if piece has native style
- `#foreign?` - Check if piece has foreign style

#### Style Manipulation
- `#foreignize` - Convert to foreign style
- `#nativize` - Convert to native style
- `#toggle_style` - Toggle between native/foreign style

#### Inherited PIN Methods
All methods from `Sashite::Pin::Piece` are available, including state queries, state manipulation, and conversion methods.

#### Conversion
- `#to_s` - Convert to PNN string representation
- `#to_pin` - Convert to underlying PIN representation
- `#inspect` - Detailed string representation for debugging

## Examples in Common Games

### Single-Style Games

```ruby
# Western Chess (both players use Chess style)
white_king = Sashite::Pnn::Piece.parse("K")      # White king
black_king = Sashite::Pnn::Piece.parse("k")      # Black king
castling_rook = Sashite::Pnn::Piece.parse("+R")  # Rook that can castle

# Japanese Shōgi (both players use Shōgi style)
white_king = Sashite::Pnn::Piece.parse("K")      # White king
promoted_pawn = Sashite::Pnn::Piece.parse("+P")  # Promoted pawn (tokin)
```

### Cross-Style Games

```ruby
# Chess vs Shōgi hybrid
chess_queen = Sashite::Pnn::Piece.parse("Q")     # Chess queen (native to first player)
shogi_gold = Sashite::Pnn::Piece.parse("G'")     # Shōgi gold (foreign to first player)
shogi_king = Sashite::Pnn::Piece.parse("k")      # Shōgi king (native to second player)
chess_knight = Sashite::Pnn::Piece.parse("n'")   # Chess knight (foreign to second player)
```

## Advanced Usage

### Chaining Operations

```ruby
piece = Sashite::Pnn::Piece.parse("k")

# Chain multiple operations
result = piece.enhance.foreignize.flip
result.to_s # => "+K'"

# Complex transformations
captured_and_converted = piece.flip.nativize.enhance
captured_and_converted.to_s # => "+K"
```

### Validation

All parsing automatically validates input according to the PNN specification:

```ruby
# Valid PNN strings
Sashite::Pnn::Piece.parse("k")      # ✓
Sashite::Pnn::Piece.parse("k'")     # ✓
Sashite::Pnn::Piece.parse("+p")     # ✓
Sashite::Pnn::Piece.parse("+p'")    # ✓

# Check validity
Sashite::Pnn.valid?("k'") # => true
Sashite::Pnn.valid?("invalid") # => false

# Invalid PNN strings raise ArgumentError
Sashite::Pnn::Piece.parse("")        # ✗ ArgumentError
Sashite::Pnn::Piece.parse("k''")     # ✗ ArgumentError
Sashite::Pnn::Piece.parse("++k")     # ✗ ArgumentError
```

## Properties of PNN

* **PIN compatibility**: All valid PIN strings are valid PNN strings
* **Style awareness**: Distinguishes pieces by their style origin
* **Rule-agnostic**: PNN does not encode legality, validity, or game-specific conditions
* **Cross-tradition support**: Enables hybrid game scenarios
* **Immutable objects**: All operations return new instances, ensuring thread safety
* **Compact format**: Minimal overhead (single character suffix for style)

## Constraints

* PNN inherits all PIN constraints (two players, 26 piece types maximum)
* Each side must have a defined native style
* Style assignment is rule-dependent and remains fixed throughout the match
* Foreign style pieces represent adoption of the opponent's style system

## Documentation

- [Official PNN Specification](https://sashite.dev/specs/pnn/1.0.0/)
- [PIN Specification](https://sashite.dev/specs/pin/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/pnn.rb/main)

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
