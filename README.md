# Snn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/snn.rb?label=Version&logo=github)](https://github.com/sashite/snn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/snn.rb/main)
![Ruby](https://github.com/sashite/snn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/snn.rb?label=License&logo=github)](https://github.com/sashite/snn.rb/raw/main/LICENSE.md)

> **SNN** (Style Name Notation) implementation for the Ruby language.

## What is SNN?

SNN (Style Name Notation) is a formal, rule-agnostic naming system for identifying **styles** in abstract strategy board games such as chess, shōgi, xiangqi, and their many variants. Each style is represented by a canonical, human-readable ASCII name (e.g., `"Chess"`, `"Shogi"`, `"Xiangqi"`, `"Minishogi"`).

This gem implements the [SNN Specification v1.0.0](https://sashite.dev/specs/snn/1.0.0/), supporting validation, parsing, and comparison of style names.

## Installation

```ruby
# In your Gemfile
gem "sashite-snn"
````

Or install manually:

```sh
gem install sashite-snn
```

## Usage

### Basic Operations

```ruby
require "sashite/snn"

# Parse SNN strings into style name objects
name = Sashite::Snn.parse("Shogi")             # => #<Snn::Name value="Shogi">
name.to_s                                      # => "Shogi"
name.value                                     # => "Shogi"

# Create from string or symbol
name = Sashite::Snn.name("Chess")              # => #<Snn::Name value="Chess">
name = Sashite::Snn::Name.new(:Xiangqi)        # => #<Snn::Name value="Xiangqi">

# Validate SNN strings
Sashite::Snn.valid?("Go9x9")                   # => true
Sashite::Snn.valid?("chess")                   # => false (must start with uppercase)
Sashite::Snn.valid?("3DChess")                 # => false (invalid character)
```

### Normalization and Comparison

```ruby
a = Sashite::Snn.parse("Chess960")
b = Sashite::Snn.parse("Chess960")

a == b                                         # => true
a.same_base_name?(Sashite::Snn.parse("Chess")) # => true if both resolve to same SIN
a.to_s # => "Chess960"
```

### Canonical Representation

```ruby
# All names are normalized to a canonical format
name = Sashite::Snn.parse("Minishogi")
name.value                                    # => "Minishogi"
name.to_s                                     # => "Minishogi"
```

### Collections and Filtering

```ruby
names = %w[Chess Shogi Makruk Antichess Minishogi].map { |n| Sashite::Snn.parse(n) }

# Filter by prefix
names.select { |n| n.value.start_with?("Mini") }.map(&:to_s)
# => ["Minishogi"]
```

## Format Specification

### Structure

```
<uppercase-letter>[<lowercase-letter | digit>]*
```

### Grammar (BNF)

```bnf
<snn> ::= <uppercase-letter> <tail>

<tail> ::= ""                                ; Single letter (e.g., "X")
        | <alphanumeric-char> <tail>         ; Extended name

<alphanumeric-char> ::= <lowercase-letter> | <digit>

<uppercase-letter> ::= "A" | "B" | "C" | ... | "Z"
<lowercase-letter> ::= "a" | "b" | "c" | ... | "z"
<digit> ::= "0" | "1" | "2" | "3" | ... | "9"
```

### Regular Expression

```ruby
/\A[A-Z][a-z0-9]*\z/
```

## Design Principles

* **Human-readable**: Names like `"Shogi"` or `"Chess960"` are intuitive and descriptive.
* **Canonical**: One valid name per game style within a given context.
* **ASCII-only**: Compatible with all systems.
* **Scalable**: Supports unlimited distinct names for current and future game variants.

## Integration with SIN

SNN names serve as the formal source for SIN character identifiers. For example:

| SNN       | SIN     |
| --------- | ------- |
| `Chess`   | `C`/`c` |
| `Shogi`   | `S`/`s` |
| `Xiangqi` | `X`/`x` |
| `Makruk`  | `M`/`m` |

Multiple SNN names may map to the same SIN character (e.g., `"Chess"` and `"Chess960"` both → `C`), but SNN provides unambiguous naming within broader contexts.

## Examples

```ruby
Sashite::Snn.parse("Chess")       # => #<Snn::Name value="Chess">
Sashite::Snn.parse("Chess960")    # => #<Snn::Name value="Chess960">
Sashite::Snn.valid?("Minishogi")  # => true
Sashite::Snn.valid?("miniShogi")  # => false
```

## API Reference

### Main Module

* `Sashite::Snn.valid?(str)` – Returns `true` if the string is valid SNN.
* `Sashite::Snn.parse(str)` – Returns a `Sashite::Snn::Name` object.
* `Sashite::Snn.name(sym_or_str)` – Alias for constructing a name.

### `Sashite::Snn::Name`

* `#value` – Returns the canonical string value.
* `#to_s` – Returns the string representation.
* `#==`, `#eql?`, `#hash` – Value-based equality.
* `#same_base_name?(other)` – Optional helper for SIN mapping equivalence.

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
