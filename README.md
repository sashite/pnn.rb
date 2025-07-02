# Pnn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pnn.rb?label=Version&logo=github)](https://github.com/sashite/pnn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pnn.rb/main)
![Ruby](https://github.com/sashite/pnn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pnn.rb?label=License&logo=github)](https://github.com/sashite/pnn.rb/raw/main/LICENSE.md)

> **PNN** (Piece Name Notation) implementation for the Ruby language.

## What is PNN?

PNN (Piece Name Notation) extends [PIN (Piece Identifier Notation)](https://sashite.dev/specs/pin/1.0.0/) to provide style-aware piece representation in abstract strategy board games. PNN adds a derivation marker that distinguishes pieces by their style origin, enabling cross-style game scenarios and piece origin tracking.

This gem implements the [PNN Specification v1.0.0](https://sashite.dev/specs/pnn/1.0.0/), providing a modern Ruby interface with immutable piece objects and full backward compatibility with PIN while adding style differentiation capabilities.

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

```ruby
require "sashite/pnn"

# Parse PNN strings into piece objects
piece = Sashite::Pnn.parse("K")          # => #<Pnn::Piece type=:K side=:first state=:normal native=true>
piece.to_s                               # => "K"
piece.type                               # => :K
piece.side                               # => :first
piece.state                              # => :normal
piece.native?                            # => true

# Create pieces directly
piece = Sashite::Pnn.piece(:K, :first)                    # => #<Pnn::Piece type=:K side=:first state=:normal native=true>
piece = Sashite::Pnn::Piece.new(:R, :second, :enhanced, false)  # => #<Pnn::Piece type=:R side=:second state=:enhanced native=false>

# Validate PNN strings
Sashite::Pnn.valid?("K")                 # => true
Sashite::Pnn.valid?("+R'")               # => true
Sashite::Pnn.valid?("invalid")           # => false

# Style derivation with apostrophe suffix
native_king = Sashite::Pnn.parse("K")    # => #<Pnn::Piece type=:K side=:first state=:normal native=true>
foreign_king = Sashite::Pnn.parse("K'")  # => #<Pnn::Piece type=:K side=:first state=:normal native=false>

native_king.to_s                         # => "K"
foreign_king.to_s                        # => "K'"

# State manipulation (returns new immutable instances)
enhanced = piece.enhance                 # => #<Pnn::Piece type=:K side=:first state=:enhanced native=true>
enhanced.to_s                            # => "+K"
diminished = piece.diminish              # => #<Pnn::Piece type=:K side=:first state=:diminished native=true>
diminished.to_s                          # => "-K"

# Style derivation manipulation
foreign_piece = piece.derive             # => #<Pnn::Piece type=:K side=:first state=:normal native=false>
foreign_piece.to_s                       # => "K'"
back_to_native = foreign_piece.underive  # => #<Pnn::Piece type=:K side=:first state=:normal native=true>
back_to_native.to_s                      # => "K"

# Side manipulation
flipped = piece.flip                     # => #<Pnn::Piece type=:K side=:second state=:normal native=true>
flipped.to_s                             # => "k"

# Type manipulation
queen = piece.with_type(:Q)              # => #<Pnn::Piece type=:Q side=:first state=:normal native=true>
queen.to_s                               # => "Q"

# Style queries
piece.native?                            # => true
foreign_king.derived?                    # => true

# State queries
piece.normal?                            # => true
enhanced.enhanced?                       # => true
diminished.diminished?                   # => true

# Side queries
piece.first_player?                      # => true
flipped.second_player?                   # => true

# Attribute access
piece.letter                             # => "K"
enhanced.prefix                          # => "+"
foreign_king.suffix                      # => "'"
piece.suffix                             # => ""

# Type and side comparison
king1 = Sashite::Pnn.parse("K")
king2 = Sashite::Pnn.parse("k")
queen = Sashite::Pnn.parse("Q")

king1.same_type?(king2)                  # => true (both kings)
king1.same_side?(queen)                  # => true (both first player)
king1.same_type?(queen)                  # => false (different types)

# Style comparison
native_king = Sashite::Pnn.parse("K")
foreign_king = Sashite::Pnn.parse("K'")

native_king.same_style?(foreign_king)    # => false (different derivation)

# Functional transformations can be chained
pawn = Sashite::Pnn.parse("P")
enemy_foreign_promoted = pawn.flip.derive.enhance  # => "+p'" (second player foreign promoted pawn)
```

## Format Specification

### Structure
```
<pin>[<suffix>]
```

### Components

- **PIN part** (`[<state>]<letter>`): Standard PIN notation
  - **Letter** (`A-Z`, `a-z`): Represents piece type and side
    - Uppercase: First player pieces
    - Lowercase: Second player pieces
  - **State** (optional prefix):
    - `+`: Enhanced state (promoted, upgraded, empowered)
    - `-`: Diminished state (weakened, restricted, temporary)
    - No prefix: Normal state

- **Derivation suffix** (optional):
  - `'`: Foreign style (piece has opposite side's native style)
  - No suffix: Native style (piece has current side's native style)

### Regular Expression
```ruby
/\A[-+]?[A-Za-z]'?\z/
```

### Examples
- `K` - First player king (native style, normal state)
- `k'` - Second player king (foreign style, normal state)
- `+R'` - First player rook (foreign style, enhanced state)
- `-p` - Second player pawn (native style, diminished state)

## Game Examples

### Cross-Style Chess vs. Shōgi

```ruby
# Match setup: First player uses Chess, Second player uses Shōgi
# Native styles: first=Chess, second=Shōgi

# Native pieces (no derivation suffix)
white_king = Sashite::Pnn.piece(:K, :first)          # => "K" (Chess king)
black_king = Sashite::Pnn.piece(:K, :second)         # => "k" (Shōgi king)

# Foreign pieces (with derivation suffix)
white_shogi_king = Sashite::Pnn.piece(:K, :first, :normal, false)   # => "K'" (Shōgi king for white)
black_chess_king = Sashite::Pnn.piece(:K, :second, :normal, false)  # => "k'" (Chess king for black)

# Promoted pieces in cross-style context
white_promoted_rook = Sashite::Pnn.parse("+R'")  # White shōgi rook promoted to Dragon King
black_promoted_pawn = Sashite::Pnn.parse("+p")   # Black shōgi pawn promoted to Tokin

white_promoted_rook.enhanced?                     # => true
white_promoted_rook.derived?                      # => true
black_promoted_pawn.enhanced?                     # => true
black_promoted_pawn.native?                       # => true
```

### Single-Style Games (PIN Compatibility)

```ruby
# Traditional Chess (both players use Chess style)
# All pieces are native, so PNN behaves exactly like PIN

white_pieces = %w[K Q +R B N P].map { |pin| Sashite::Pnn.parse(pin) }
black_pieces = %w[k q +r b n p].map { |pin| Sashite::Pnn.parse(pin) }

white_pieces.all?(&:native?)                     # => true
black_pieces.all?(&:native?)                     # => true

# PNN strings match PIN strings for native pieces
white_pieces.map(&:to_s)                         # => ["K", "Q", "+R", "B", "N", "P"]
black_pieces.map(&:to_s)                         # => ["k", "q", "+r", "b", "n", "p"]
```

### Style Mutation During Gameplay

```ruby
# Simulate capture with style change (Ōgi rules)
chess_queen = Sashite::Pnn.parse("q'")           # Black chess queen (foreign for shōgi player)
captured = chess_queen.flip.with_type(:P).underive  # Becomes white native pawn

chess_queen.to_s                                 # => "q'" (black foreign queen)
captured.to_s                                    # => "P" (white native pawn)

# Style derivation changes during gameplay
shogi_piece = Sashite::Pnn.parse("r")           # Black shōgi rook (native)
foreign_piece = shogi_piece.derive              # Convert to foreign style
foreign_piece.to_s                              # => "r'" (black foreign rook)
```

## API Reference

### Main Module Methods

- `Sashite::Pnn.valid?(pnn_string)` - Check if string is valid PNN notation
- `Sashite::Pnn.parse(pnn_string)` - Parse PNN string into Piece object
- `Sashite::Pnn.piece(type, side, state = :normal, native = true)` - Create piece instance directly

### Piece Class

#### Creation and Parsing
- `Sashite::Pnn::Piece.new(type, side, state = :normal, native = true)` - Create piece instance
- `Sashite::Pnn::Piece.parse(pnn_string)` - Parse PNN string (same as module method)
- `Sashite::Pnn::Piece.valid?(pnn_string)` - Validate PNN string (class method)

#### Attribute Access
- `#type` - Get piece type (symbol :A to :Z, always uppercase)
- `#side` - Get player side (:first or :second)
- `#state` - Get state (:normal, :enhanced, or :diminished)
- `#native` - Get style derivation (true for native, false for foreign)
- `#letter` - Get letter representation (string, case determined by side)
- `#prefix` - Get state prefix (string: "+", "-", or "")
- `#suffix` - Get derivation suffix (string: "'" or "")
- `#to_s` - Convert to PNN string representation

#### Style Queries
- `#native?` - Check if native style (current side's native style)
- `#derived?` - Check if foreign style (opposite side's native style)
- `#foreign?` - Alias for `#derived?`

#### State Queries
- `#normal?` - Check if normal state (no modifiers)
- `#enhanced?` - Check if enhanced state
- `#diminished?` - Check if diminished state

#### Side Queries
- `#first_player?` - Check if first player piece
- `#second_player?` - Check if second player piece

#### State Transformations (immutable - return new instances)
- `#enhance` - Create enhanced version
- `#unenhance` - Remove enhanced state
- `#diminish` - Create diminished version
- `#undiminish` - Remove diminished state
- `#normalize` - Remove all state modifiers

#### Style Transformations (immutable - return new instances)
- `#derive` - Convert to foreign style (add derivation suffix)
- `#underive` - Convert to native style (remove derivation suffix)
- `#flip` - Switch player (change side)

#### Attribute Transformations (immutable - return new instances)
- `#with_type(new_type)` - Create piece with different type
- `#with_side(new_side)` - Create piece with different side
- `#with_state(new_state)` - Create piece with different state
- `#with_derivation(native)` - Create piece with different derivation

#### Comparison Methods
- `#same_type?(other)` - Check if same piece type
- `#same_side?(other)` - Check if same side
- `#same_state?(other)` - Check if same state
- `#same_style?(other)` - Check if same style derivation
- `#==(other)` - Full equality comparison

### Constants
- `Sashite::Pnn::Piece::PNN_PATTERN` - Regular expression for PNN validation
- `Sashite::Pnn::Piece::NATIVE` - Constant for native style (`true`)
- `Sashite::Pnn::Piece::FOREIGN` - Constant for foreign style (`false`)

## Advanced Usage

### Style Derivation Examples

```ruby
# Understanding native vs. foreign pieces
# In a Chess vs. Shōgi match:
# - First player native style: Chess
# - Second player native style: Shōgi

native_chess_king = Sashite::Pnn.parse("K")      # First player native (Chess king)
foreign_shogi_king = Sashite::Pnn.parse("K'")    # First player foreign (Shōgi king)

native_shogi_king = Sashite::Pnn.parse("k")      # Second player native (Shōgi king)
foreign_chess_king = Sashite::Pnn.parse("k'")    # Second player foreign (Chess king)

# Style queries
native_chess_king.native?                        # => true
foreign_shogi_king.derived?                      # => true
native_shogi_king.native?                        # => true
foreign_chess_king.derived?                      # => true
```

### Immutable Transformations
```ruby
# All transformations return new instances
original = Sashite::Pnn.piece(:K, :first)
enhanced = original.enhance
derived = original.derive
flipped = original.flip

# Original piece is never modified
puts original.to_s    # => "K"
puts enhanced.to_s    # => "+K"
puts derived.to_s     # => "K'"
puts flipped.to_s     # => "k"

# Transformations can be chained
result = original.flip.derive.enhance.with_type(:Q)
puts result.to_s      # => "+q'"
```

### Cross-Style Game State Management
```ruby
class CrossStyleGameBoard
  def initialize(first_style, second_style)
    @first_style = first_style
    @second_style = second_style
    @pieces = {}
  end

  def place(square, piece)
    @pieces[square] = piece
  end

  def capture_with_style_change(from_square, to_square, new_type = nil)
    captured = @pieces[to_square]
    capturing = @pieces.delete(from_square)

    return nil unless captured && capturing

    # Style mutation: captured piece becomes native to capturing side
    mutated = captured.flip.underive
    mutated = mutated.with_type(new_type) if new_type

    @pieces[to_square] = capturing
    mutated  # Return mutated captured piece for hand
  end

  def pieces_by_style_derivation
    {
      native: @pieces.select { |_, piece| piece.native? },
      foreign: @pieces.select { |_, piece| piece.derived? }
    }
  end
end

# Usage
board = CrossStyleGameBoard.new(:chess, :shogi)
board.place("e1", Sashite::Pnn.piece(:K, :first))               # Chess king
board.place("e8", Sashite::Pnn.piece(:K, :second))              # Shōgi king
board.place("d4", Sashite::Pnn.piece(:Q, :first, :normal, false))  # Chess queen using Shōgi style

analysis = board.pieces_by_style_derivation
puts analysis[:native].size    # => 2
puts analysis[:foreign].size   # => 1
```

### PIN Compatibility Layer
```ruby
# PNN is fully backward compatible with PIN
def convert_pin_to_pnn(pin_string)
  # All PIN strings are valid PNN strings (native pieces)
  Sashite::Pnn.parse(pin_string)
end

def convert_pnn_to_pin(pnn_piece)
  # Only native PNN pieces can be converted to PIN
  return nil unless pnn_piece.native?

  "#{pnn_piece.prefix}#{pnn_piece.letter}"
end

# Usage
pin_pieces = %w[K Q +R -P k q r p]
pnn_pieces = pin_pieces.map { |pin| convert_pin_to_pnn(pin) }

pnn_pieces.all?(&:native?)                    # => true
pnn_pieces.map { |p| convert_pnn_to_pin(p) }  # => ["K", "Q", "+R", "-P", "k", "q", "r", "p"]
```

### Move Validation Example
```ruby
def can_promote_in_style?(piece, target_rank, style_rules)
  return false unless piece.normal?  # Already promoted pieces can't promote again

  case [piece.type, piece.native? ? style_rules[:native] : style_rules[:foreign]]
  when [:P, :chess]  # Chess pawn
    (piece.first_player? && target_rank == 8) ||
    (piece.second_player? && target_rank == 1)
  when [:P, :shogi]  # Shōgi pawn
    (piece.first_player? && target_rank >= 7) ||
    (piece.second_player? && target_rank <= 3)
  when [:R, :shogi], [:B, :shogi]  # Shōgi major pieces
    true
  else
    false
  end
end

# Usage
chess_pawn = Sashite::Pnn.piece(:P, :first)
shogi_pawn = Sashite::Pnn.piece(:P, :first, :normal, false)

style_rules = { native: :chess, foreign: :shogi }

puts can_promote_in_style?(chess_pawn, 8, style_rules)  # => true (chess pawn on 8th rank)
puts can_promote_in_style?(shogi_pawn, 8, style_rules)  # => true (shogi pawn on 8th rank)
```

## Implementation Architecture

This gem uses **composition over inheritance** by building upon the proven [sashite-pin](https://github.com/sashite/pin.rb) gem:

- **PIN Foundation**: All type, side, and state logic is handled by an internal `Pin::Piece` object
- **PNN Extension**: Only the derivation (`native`) attribute and related methods are added
- **Delegation Pattern**: Core PIN methods are delegated to the internal PIN piece
- **Immutability**: All transformations return new instances, maintaining functional programming principles

This architecture ensures:
- **Reliability**: Reuses battle-tested PIN logic
- **Maintainability**: PIN updates automatically benefit PNN
- **Consistency**: PIN and PNN pieces behave identically for shared attributes
- **Performance**: Minimal overhead over pure PIN implementation

## Protocol Mapping

Following the [Game Protocol](https://sashite.dev/game-protocol/):

| Protocol Attribute | PNN Encoding | Examples | Notes |
|-------------------|--------------|----------|-------|
| **Type** | ASCII letter choice | `K`/`k` = King, `P`/`p` = Pawn | Type is always stored as uppercase symbol (`:K`, `:P`) |
| **Side** | Letter case in display | `K` = First player, `k` = Second player | Case is determined by side during rendering |
| **State** | Optional prefix | `+K` = Enhanced, `-K` = Diminished, `K` = Normal | |
| **Style** | Derivation suffix | `K` = Native style, `K'` = Foreign style | |

**Style Derivation Logic**:
- **No suffix**: Piece has the **native style** of its current side
- **Apostrophe suffix (`'`)**: Piece has the **foreign style** (opposite side's native style)

**Canonical principle**: Identical pieces must have identical PNN representations.

## Properties

* **PIN Compatible**: All valid PIN strings are valid PNN strings
* **Style Aware**: Distinguishes pieces by their style origin through derivation markers
* **ASCII Compatible**: Maximum portability across systems
* **Rule-Agnostic**: Independent of specific game mechanics
* **Compact Format**: Minimal character usage (1-3 characters per piece)
* **Visual Distinction**: Clear player and style differentiation
* **Protocol Compliant**: Complete implementation of Sashité piece attributes
* **Immutable**: All piece instances are frozen and transformations return new objects
* **Functional**: Pure functions with no side effects

## Implementation Notes

### Style Derivation Convention

PNN follows a strict style derivation convention:

1. **Native pieces** (no suffix): Use the current side's native style
2. **Foreign pieces** (`'` suffix): Use the opposite side's native style
3. **Match context**: Each side has a defined native style for the entire match
4. **Style mutations**: Pieces can change derivation through gameplay mechanics

### Example Flow

```ruby
# Match context: First player=Chess, Second player=Shōgi
# Input: "K'" (first player foreign)
# ↓ Parsing
# type: :K, side: :first, state: :normal, native: false
# ↓ Style resolution
# Effective style: Shōgi (second player's native style)
# ↓ Display
# PNN: "K'" (first player king with foreign/Shōgi style)
```

This ensures that `parse(pnn).to_s == pnn` for all valid PNN strings while enabling cross-style gameplay.

## System Constraints

- **Maximum 26 piece types** per game system (one per ASCII letter)
- **Exactly 2 players** (uppercase/lowercase distinction)
- **3 state levels** (enhanced, normal, diminished)
- **2 style derivations** (native, foreign)
- **Style context dependency**: Requires match-level side-style associations

## Related Specifications

- [PIN](https://sashite.dev/specs/pin/1.0.0/) - Piece Identifier Notation (style-agnostic base)
- [Game Protocol](https://sashite.dev/game-protocol/) - Conceptual foundation for abstract strategy board games
- [SNN](https://sashite.dev/specs/snn/1.0.0/) - Style Name Notation
- [GAN](https://sashite.dev/specs/gan/1.0.0/) - General Actor Notation (alternative style-aware format)
- [CELL](https://sashite.dev/specs/cell/) - Board position coordinates
- [HAND](https://sashite.dev/specs/hand/) - Reserve location notation
- [PMN](https://sashite.dev/specs/pmn/) - Portable Move Notation

## Documentation

- [Official PNN Specification v1.0.0](https://sashite.dev/specs/pnn/1.0.0/)
- [PNN Examples Documentation](https://sashite.dev/specs/pnn/1.0.0/examples/)
- [Game Protocol Foundation](https://sashite.dev/game-protocol/)
- [API Documentation](https://rubydoc.info/github/sashite/pnn.rb/main)

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
