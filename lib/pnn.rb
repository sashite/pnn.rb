# frozen_string_literal: true

require_relative File.join("pnn", "dumper")
require_relative File.join("pnn", "parser")
require_relative File.join("pnn", "validator")

# This module provides a Ruby interface for serialization and
# deserialization of piece identifiers in PNN format.
#
# PNN (Piece Name Notation) defines a consistent and rule-agnostic
# format for representing pieces in abstract strategy board games.
#
# @see https://sashite.dev/documents/pnn/1.0.0/
module Pnn
  # Serializes a piece identifier into a PNN string.
  #
  # @param prefix [String, nil] Optional modifier preceding the letter ('+' or '-')
  # @param letter [String] A single ASCII letter ('a-z' or 'A-Z')
  # @param suffix [String, nil] Optional modifier following the letter ('=', '<', or '>')
  # @return [String] PNN notation string
  # @raise [ArgumentError] If any parameter is invalid
  # @example
  #   Pnn.dump(letter: "k", suffix: "=")
  #   # => "k="
  def self.dump(letter:, prefix: nil, suffix: nil)
    Dumper.dump(letter:, prefix:, suffix:)
  end

  # Parses a PNN string into its component parts.
  #
  # @param pnn_string [String] PNN notation string
  # @return [Hash] Hash containing the parsed piece data with the following keys:
  #   - :letter [String] - The base letter identifier
  #   - :prefix [String, nil] - The prefix modifier if present
  #   - :suffix [String, nil] - The suffix modifier if present
  # @raise [ArgumentError] If the PNN string is invalid
  # @example
  #   Pnn.parse("+k=")
  #   # => { letter: "k", prefix: "+", suffix: "=" }
  def self.parse(pnn_string)
    Parser.parse(pnn_string)
  end

  # Safely parses a PNN string into its component parts without raising exceptions.
  #
  # @param pnn_string [String] PNN notation string
  # @return [Hash, nil] Hash containing the parsed piece data or nil if parsing fails
  # @example
  #   # Valid PNN string
  #   Pnn.safe_parse("+k=")
  #   # => { letter: "k", prefix: "+", suffix: "=" }
  #
  #   # Invalid PNN string
  #   Pnn.safe_parse("invalid")
  #   # => nil
  def self.safe_parse(pnn_string)
    Parser.safe_parse(pnn_string)
  end

  # Validates if the given string is a valid PNN string
  #
  # @param pnn_string [String] PNN string to validate
  # @return [Boolean] True if the string is a valid PNN string
  # @example
  #   Pnn.valid?("k=") # => true
  #   Pnn.valid?("invalid") # => false
  def self.valid?(pnn_string)
    Validator.valid?(pnn_string)
  end
end
