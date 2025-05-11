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
- `<suffix>` is an optional modifier following the letter (`=`, `<`, or `>`)

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
result = Pnn.parse("k=")
# => { letter: "k", suffix: "=" }

# With both prefix and suffix
result = Pnn.parse("+k=")
# => { letter: "k", prefix: "+", suffix: "=" }
```

### Safe Parsing

Parse a PNN string without raising exceptions:

```ruby
require "pnn"

# Valid PNN string
result = Pnn.safe_parse("+k=")
# => { letter: "k", prefix: "+", suffix: "=" }

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
Pnn.dump(letter: "k", suffix: "=")
# => "k="

# With both prefix and suffix
Pnn.dump(letter: "p", prefix: "+", suffix: ">")
# => "+p>"
```

### Validation

Check if a string is valid PNN notation:

```ruby
require "pnn"

Pnn.valid?("k")      # => true
Pnn.valid?("+p")     # => true
Pnn.valid?("k=")     # => true
Pnn.valid?("+p>")    # => true

Pnn.valid?("")       # => false
Pnn.valid?("kp")     # => false
Pnn.valid?("++k")    # => false
Pnn.valid?("k==")    # => false
```

### Piece Modifiers

PNN supports prefixes and suffixes for pieces to denote various states or capabilities:

- **Prefix `+`**: Alternative or enhanced state
  - Example in shogi: `+p` may represent a promoted pawn

- **Prefix `-`**: Diminished or restricted state
  - Example: `-k` may represent a king with restricted movement

- **Suffix `=`**: Bidirectional or dual-option state
  - Example in chess: `k=` may represent a king eligible for both kingside and queenside castling

- **Suffix `<`**: Left-side constraint or condition
  - Example in chess: `k<` may represent a king eligible for queenside castling only
  - Example in chess: `p<` may represent a pawn that may be captured _en passant_ from the left

- **Suffix `>`**: Right-side constraint or condition
  - Example in chess: `k>` may represent a king eligible for kingside castling only
  - Example in chess: `p>` may represent a pawn that may be captured en passant from the right

These modifiers have no defined semantics in the PNN specification itself but provide a flexible framework for representing piece-specific conditions while maintaining PNN's rule-agnostic nature.

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

This project is maintained by [Sashité](https://sashite.com/) - a project dedicated to promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
