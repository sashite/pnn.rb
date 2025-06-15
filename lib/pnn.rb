# frozen_string_literal: true

require_relative File.join("pnn", "piece")

# This module provides a Ruby interface for working with piece identifiers
# in PNN (Piece Name Notation) format.
#
# PNN defines a consistent and rule-agnostic format for representing pieces
# in abstract strategy board games, providing a standardized way to identify
# pieces independent of any specific game rules or mechanics.
#
# The primary interface is the `Pnn::Piece` class, which provides an
# object-oriented API for creating, parsing, and manipulating piece representations.
#
# @example Basic usage with the Piece class
#   # Parse a PNN string
#   piece = Pnn::Piece.parse("k")
#
#   # Create directly
#   piece = Pnn::Piece.new("k")
#
#   # Manipulate states
#   enhanced = piece.enhance
#   enhanced.to_s  # => "+k"
#
#   # Change ownership
#   flipped = piece.flip
#   flipped.to_s  # => "K"
#
# @see https://sashite.dev/documents/pnn/1.0.0/
# @see Pnn::Piece
module Pnn
  # Validate if the given string is a valid PNN string.
  #
  # @param pnn_string [String] PNN string to validate
  # @return [Boolean] True if the string is a valid PNN string
  # @example
  #   Pnn.valid?("k'")     # => true
  #   Pnn.valid?("invalid") # => false
  def self.valid?(pnn_string)
    Piece.parse(pnn_string).to_s == pnn_string
  rescue ArgumentError
    false
  end

  # Create a new piece instance.
  #
  # This is a convenience method that delegates to `Pnn::Piece.new`.
  #
  # @param letter [String] single ASCII letter (a-z or A-Z)
  # @param enhanced [Boolean] whether the piece has enhanced state
  # @param diminished [Boolean] whether the piece has diminished state
  # @param intermediate [Boolean] whether the piece has intermediate state
  # @return [Pnn::Piece] new piece instance
  # @raise [ArgumentError] if parameters are invalid
  # @example
  #   piece = Pnn.piece("k", enhanced: true)
  #   piece.to_s  # => "+k"
  def self.piece(letter, enhanced: false, diminished: false, intermediate: false)
    Piece.new(
      letter,
      enhanced:,
      diminished:,
      intermediate:
    )
  end
end
