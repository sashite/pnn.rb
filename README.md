# Pnn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pnn.rb?label=Version&logo=github)](https://github.com/sashite/pnn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pnn.rb/main)
![Ruby](https://github.com/sashite/pnn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pnn.rb?label=License&logo=github)](https://github.com/sashite/pnn.rb/raw/main/LICENSE.md)

> **PNN** (Piece Name Notation) support for the Ruby language.

## What is PNN?

PNN (Piece Name Notation) is a consistent and rule-agnostic format for representing pieces in abstract strategy board games. It defines a standardized way to identify and represent pieces independent of any specific game rules or mechanics.

This gem implements the [PNN Specification v1.0.0](https://sashite.dev/documents/pnn/1.0.0/), providing a Ruby interface for working with piece representations through an intuitive object-oriented API.

## Installation

```ruby
# In your Gemfile
gem "pnn"
```

Or install manually:

```sh
gem install pnn
```

## PNN Format

A PNN record consists of a single ASCII letter that represents a piece, with optional prefixes and/or suffixes to indicate modifiers or state information:

```
[<prefix>]<letter>[<suffix>]
```

Where:
- `<letter>` is a single ASCII letter (`a-z` or `A-Z`), with uppercase representing the first player's pieces and lowercase representing the second player's pieces
- `<prefix>` is an optional modifier preceding the letter (`+` for Enhanced or `-` for Diminished state)
- `<suffix>` is an optional modifier following the letter (`'` for Intermediate state)

## Basic Usage

### Creating Piece Objects

The primary interface is the `Pnn::Piece` class, which represents a single piece in PNN format:

```ruby
require "pnn"

# Parse a PNN string into a piece object
piece = Pnn::Piece.parse("k")
# => #<Pnn::Piece:0x... @letter="k">

# With modifiers
enhanced_piece = Pnn::Piece.parse("+k'")
# => #<Pnn::Piece:0x... @letter="k", @enhanced=true, @intermediate=true>

# Create directly with constructor
piece = Pnn::Piece.new("k")
enhanced_piece = Pnn::Piece.new("k", enhanced: true, intermediate: true)

# Convenience method
piece = Pnn.piece("k", enhanced: true)
```

### Converting to PNN String

Convert a piece object back to its PNN string representation:

```ruby
piece = Pnn::Piece.parse("k")
piece.to_s
# => "k"

enhanced_piece = Pnn::Piece.parse("+k'")
enhanced_piece.to_s
# => "+k'"
```

### State Manipulation

Create new piece instances with different states:

```ruby
piece = Pnn::Piece.parse("k")

# Enhanced state (+ prefix)
enhanced = piece.enhance
enhanced.to_s # => "+k"

# Diminished state (- prefix)
diminished = piece.diminish
diminished.to_s # => "-k"

# Intermediate state (' suffix)
intermediate = piece.intermediate
intermediate.to_s # => "k'"

# Remove states
restored = enhanced.unenhance
restored.to_s # => "k"

# Combine states
complex = piece.enhance.intermediate
complex.to_s # => "+k'"
```

### Ownership Changes

Change piece ownership (case conversion):

```ruby
white_king = Pnn::Piece.parse("K")
black_king = white_king.flip
black_king.to_s # => "k"

# Works with modifiers too
enhanced_white = Pnn::Piece.parse("+K'")
enhanced_black = enhanced_white.flip
enhanced_black.to_s # => "+k'"
```

### Clean State

Get a piece without any modifiers:

```ruby
complex_piece = Pnn::Piece.parse("+k'")
clean_piece = complex_piece.bare
clean_piece.to_s # => "k"
```

## State Modifier Methods

The `Pnn::Piece` class provides methods to manipulate piece states:

| Method | Description | Example |
|--------|-------------|---------|
| `enhance` | Add Enhanced state (`+` prefix) | `k` → `+k` |
| `unenhance` | Remove Enhanced state | `+k` → `k` |
| `diminish` | Add Diminished state (`-` prefix) | `k` → `-k` |
| `undiminish` | Remove Diminished state | `-k` → `k` |
| `intermediate` | Add Intermediate state (`'` suffix) | `k` → `k'` |
| `unintermediate` | Remove Intermediate state | `k'` → `k` |
| `bare` | Remove all modifiers | `+k'` → `k` |
| `flip` | Change ownership (case) | `K` → `k`, `k` → `K` |

All state manipulation methods return new `Pnn::Piece` instances, leaving the original unchanged (immutable design).

## Piece Modifiers

PNN supports prefixes and suffixes for pieces to denote various states or capabilities. It's important to note that these modifiers are rule-agnostic - they provide a framework for representing piece states, but their specific meaning is determined by the game implementation:

- **Enhanced state (`+`)**: Represents pieces with enhanced capabilities
  - Example in shogi: `+p` represents a promoted pawn (tokin)
  - Example in chess variants: `+Q` might represent a queen with special powers

- **Diminished state (`-`)**: Represents pieces with reduced capabilities
  - Example in variants: `-R` might represent a rook with restricted movement
  - Example in chess: `-N` could indicate a knight that has been partially immobilized

- **Intermediate state (`'`)**: Represents pieces with special temporary states
  - Example in chess: `R'` represents a rook that can still be used for castling
  - Example in chess: `P'` represents a pawn that can be captured en passant
  - Example in variants: `B'` might indicate a bishop with a special one-time ability

These modifiers have no intrinsic semantics in the PNN specification itself. They merely provide a flexible framework for representing piece-specific conditions or states while maintaining PNN's rule-agnostic nature.

## Examples of PNN in Common Games

### Chess Examples

```ruby
# Standard pieces
king = Pnn::Piece.parse("K")           # White king
black_king = Pnn::Piece.parse("k")     # Black king
queen = Pnn::Piece.parse("Q")          # White queen

# Create pieces directly
king = Pnn::Piece.new("K")             # White king
black_king = Pnn::Piece.new("k")       # Black king

# Pieces with special states
unmoved_rook = Pnn::Piece.parse("R'") # Rook that can castle
en_passant_pawn = Pnn::Piece.parse("P'") # Pawn vulnerable to en passant

# Creating modified pieces
promoted_pawn = Pnn::Piece.parse("p").enhance # "+p"
weakened_queen = Pnn::Piece.parse("Q").diminish # "-Q"

# Or create directly with modifiers
promoted_pawn = Pnn::Piece.new("p", enhanced: true) # "+p"
weakened_queen = Pnn::Piece.new("Q", diminished: true) # "-Q"

# Using convenience method
special_knight = Pnn.piece("N", intermediate: true) # "N'"
```

### Shogi Examples

```ruby
# Standard pieces
king = Pnn::Piece.parse("K")           # Oushou (King)
pawn = Pnn::Piece.parse("P")           # Fuhyou (Pawn)

# Create directly
king = Pnn::Piece.new("K")             # Oushou (King)
pawn = Pnn::Piece.new("P")             # Fuhyou (Pawn)

# Promoted pieces
tokin = Pnn::Piece.parse("P").enhance # "+P" (Promoted pawn)
narikyou = Pnn::Piece.parse("L").enhance # "+L" (Promoted lance)

# Or create promoted pieces directly
tokin = Pnn::Piece.new("P", enhanced: true) # "+P"
narikyou = Pnn::Piece.new("L", enhanced: true) # "+L"

# Using convenience method
promoted_silver = Pnn.piece("S", enhanced: true) # "+S"

# Converting between players (capture and drop)
enemy_piece = Pnn::Piece.parse("p")
captured_piece = enemy_piece.flip.bare # "P" (now belongs to other player, no modifiers)
```

## Advanced Usage

### Chaining State Changes

```ruby
piece = Pnn::Piece.parse("k")

# Chain multiple state changes
complex_piece = piece.enhance.intermediate.flip
complex_piece.to_s # => "+K'"

# Reverse the changes
simple_piece = complex_piece.unenhance.unintermediate.flip
simple_piece.to_s # => "k"
```

### Validation

All parsing automatically validates input according to the PNN specification:

```ruby
# Valid PNN strings
Pnn::Piece.parse("k")      # ✓
Pnn::Piece.parse("+p")     # ✓
Pnn::Piece.parse("K'")     # ✓
Pnn::Piece.parse("+p'")    # ✓

# Valid constructor calls
Pnn::Piece.new("k") # ✓
Pnn::Piece.new("p", enhanced: true) # ✓
Pnn::Piece.new("K", intermediate: true) # ✓
Pnn::Piece.new("p", enhanced: true, intermediate: true) # ✓

# Convenience method
Pnn.piece("k", enhanced: true) # ✓

# Check validity
Pnn.valid?("k'") # => true
Pnn.valid?("invalid") # => false

# Invalid PNN strings raise ArgumentError
Pnn::Piece.parse("")       # ✗ ArgumentError
Pnn::Piece.parse("kp")     # ✗ ArgumentError
Pnn::Piece.parse("++k")    # ✗ ArgumentError
Pnn::Piece.parse("k''")    # ✗ ArgumentError

# Invalid constructor calls raise ArgumentError
Pnn::Piece.new("")         # ✗ ArgumentError
Pnn::Piece.new("kp")       # ✗ ArgumentError
Pnn::Piece.new("k", enhanced: true, diminished: true) # ✗ ArgumentError
```

### Inspection and Debugging

```ruby
piece = Pnn::Piece.parse("+k'")

# Get detailed information
piece.inspect
# => "#<Pnn::Piece:0x... letter='k' enhanced=true intermediate=true>"

# Check individual states
piece.enhanced?      # => true
piece.diminished?    # => false
piece.intermediate?  # => true
piece.uppercase?     # => false (it's lowercase 'k')
piece.lowercase?     # => true
```

## API Reference

### Module Methods

- `Pnn.valid?(pnn_string)` - Check if a string is valid PNN notation
- `Pnn.piece(letter, **options)` - Convenience method to create pieces

### Pnn::Piece Class Methods

- `Pnn::Piece.parse(pnn_string)` - Parse a PNN string into a piece object
- `Pnn::Piece.new(letter, **options)` - Create a new piece instance

### Instance Methods

#### State Queries
- `#enhanced?` - Check if piece has enhanced state
- `#diminished?` - Check if piece has diminished state
- `#intermediate?` - Check if piece has intermediate state
- `#bare?` - Check if piece has no modifiers
- `#uppercase?` - Check if piece belongs to first player
- `#lowercase?` - Check if piece belongs to second player

#### State Manipulation
- `#enhance` - Add enhanced state
- `#unenhance` - Remove enhanced state
- `#diminish` - Add diminished state
- `#undiminish` - Remove diminished state
- `#intermediate` - Add intermediate state
- `#unintermediate` - Remove intermediate state
- `#bare` - Remove all modifiers
- `#flip` - Change ownership (case)

#### Conversion
- `#to_s` - Convert to PNN string representation
- `#inspect` - Detailed string representation for debugging

## Properties of PNN

* **Rule-agnostic**: PNN does not encode legality, validity, or game-specific conditions.
* **Canonical representation**: Ensures that equivalent pieces yield identical strings.
* **State modifiers**: Express special conditions without compromising rule neutrality.
* **Immutable objects**: All state changes return new instances, ensuring thread safety.

## Constraints

* PNN supports exactly **two players**.
* Players are assigned distinct casing: **uppercase letters** (`A-Z`) represent pieces of the player who moves first in the initial position; **lowercase letters** (`a-z`) represent the second player.
* A maximum of **26 unique piece types per player** is allowed, as identifiers must use single letters (`a-z` or `A-Z`).
* Modifiers can only be applied to pieces **on the board**, as they express state information. Pieces held off the board (e.g., pieces in hand or captured pieces) must never include modifiers; only the base letter identifier is used.

## Documentation

- [Official PNN Specification](https://sashite.dev/documents/pnn/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/pnn.rb/main)

## License

The [gem](https://rubygems.org/gems/pnn) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
