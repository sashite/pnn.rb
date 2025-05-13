# Pnn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/pnn.rb?label=Version&logo=github)](https://github.com/sashite/pnn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/pnn.rb/main)
![Ruby](https://github.com/sashite/pnn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/pnn.rb?label=License&logo=github)](https://github.com/sashite/pnn.rb/raw/main/LICENSE.md)

> **PNN** (Piece Name Notation) support for the Ruby language.

## What is PNN?

PNN (Piece Name Notation) is a consistent and rule-agnostic format for representing pieces in abstract strategy board games. It defines a standardized way to identify and represent pieces independent of any specific game rules or mechanics.

This gem implements the [PNN Specification v1.0.0](https://sashite.dev/documents/pnn/1.0.0/), providing a Ruby interface for:
- Serializing piece identifiers to PNN strings
- Parsing PNN strings into their component parts
- Validating PNN strings according to the specification

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
- `<prefix>` is an optional modifier preceding the letter (`+` or `-`)
- `<suffix>` is an optional modifier following the letter (`'`)

## Basic Usage

### Parsing PNN Strings

Convert a PNN string into a structured Ruby hash:

```ruby
require "pnn"

# Basic letter
result = Pnn.parse("k")
# => { letter: "k" }

# With prefix
result = Pnn.parse("+k")
# => { letter: "k", prefix: "+" }

# With suffix
result = Pnn.parse("k'")
# => { letter: "k", suffix: "'" }

# With both prefix and suffix
result = Pnn.parse("+k'")
# => { letter: "k", prefix: "+", suffix: "'" }
```

### Safe Parsing

Parse a PNN string without raising exceptions:

```ruby
require "pnn"

# Valid PNN string
result = Pnn.safe_parse("+k'")
# => { letter: "k", prefix: "+", suffix: "'" }

# Invalid PNN string
result = Pnn.safe_parse("invalid pnn string")
# => nil
```

### Creating PNN Strings

Convert piece components into a PNN string:

```ruby
require "pnn"

# Basic letter
Pnn.dump(letter: "k")
# => "k"

# With prefix
Pnn.dump(letter: "p", prefix: "+")
# => "+p"

# With suffix
Pnn.dump(letter: "k", suffix: "'")
# => "k'"

# With both prefix and suffix
Pnn.dump(letter: "p", prefix: "+", suffix: "'")
# => "+p'"
```

### Validation

Check if a string is valid PNN notation:

```ruby
require "pnn"

Pnn.valid?("k")      # => true
Pnn.valid?("+p")     # => true
Pnn.valid?("k'")     # => true
Pnn.valid?("+p'")    # => true

Pnn.valid?("")       # => false
Pnn.valid?("kp")     # => false
Pnn.valid?("++k")    # => false
Pnn.valid?("k''")    # => false
```

### Piece Modifiers

PNN supports prefixes and suffixes for pieces to denote various states or capabilities. It's important to note that these modifiers are rule-agnostic - they provide a framework for representing piece states, but their specific meaning is determined by the game implementation:

- **Prefix `+`**: Enhanced state
  - Example in shogi: `+p` represents a promoted pawn with enhanced movement capabilities
  - Example in chess variants: `+Q` might represent a queen with special powers

- **Prefix `-`**: Diminished state
  - Example in variants: `-R` might represent a rook with restricted movement abilities
  - Example in weakened pieces: `-N` could indicate a knight that has been partially immobilized

- **Suffix `'`**: Intermediate state
  - Example in chess: `R'` represents a rook that can still be used for castling
  - Example in chess: `P'` represents a pawn that can be captured en passant
  - Example in variants: `B'` might indicate a bishop with a special one-time ability

These modifiers have no intrinsic semantics in the PNN specification itself. They merely provide a flexible framework for representing piece-specific conditions or states while maintaining PNN's rule-agnostic nature. Game implementations are responsible for interpreting these modifiers according to their specific rules.

## Examples of PNN in Common Games

The following examples demonstrate how PNN might be used in familiar games. Remember that PNN itself defines only the notation format, not the game-specific interpretations.

### Chess Examples

In the context of chess:

```
K       # King (first player)
k       # King (second player)
Q       # Queen (first player)
R'      # Rook that has not moved yet and can be used for castling
P'      # Pawn that can be captured en passant
```

### Shogi Examples

In the context of shogi:

```
K       # King (first player)
k       # King (second player)
+P      # Promoted pawn (tokin)
+L      # Promoted lance (narikyou)
```

### Example: A Complete Chess Position with PNN

A chess position might contain a mix of standard and modified pieces. Here's an example after the moves 1. e4 c5 2. e5 d5:

```
r' n  b  q  k  b  n  r'    # Eighth rank with unmoved rooks (castling rights)
p  p  .  .  p  p  p  p     # Seventh rank pawns (d and c pawns have moved)
.  .  .  .  .  .  .  .     # Empty sixth rank
.  .  p  p' P  .  .  .     # Fifth rank with pawn that can be captured en passant (d5) and other pawns
.  .  .  .  .  .  .  .     # Empty fourth rank
.  .  .  .  .  .  .  .     # Empty third rank
P  P  P  P  .  P  P  P     # Second rank pawns (e pawn has moved)
R' N  B  Q  K  B  N  R'    # First rank with unmoved rooks (castling rights)
```

In this position, White could capture Black's queen pawn (d5) en passant with the e5 pawn moving to d6.

Note: The above representation is merely illustrative; PNN itself only defines the notation for individual pieces, not complete board states.

## Properties of PNN

* **Rule-agnostic**: PNN does not encode legality, validity, or game-specific conditions.
* **Canonical representation**: Ensures that equivalent pieces yield identical strings.
* **State modifiers**: Express special conditions without compromising rule neutrality.

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
