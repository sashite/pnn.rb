# frozen_string_literal: true

require_relative "pnn/name"

module Sashite
  # PNN (Piece Name Notation) implementation for Ruby
  #
  # Provides a formal naming system for identifying pieces in abstract strategy board games.
  # PNN uses canonical, human-readable ASCII names with optional state modifiers and case
  # encoding for player assignment. It supports unlimited unique piece identifiers with
  # consistent, rule-agnostic semantics.
  #
  # Format: [<state-modifier>]<case-consistent-name>
  #
  # Examples:
  #   "KING"        - First player king (normal state)
  #   "queen"       - Second player queen (normal state)
  #   "+ROOK"       - First player rook (enhanced state)
  #   "-pawn"       - Second player pawn (diminished state)
  #   "BISHOP"      - First player bishop (normal state)
  #
  # See: https://sashite.dev/specs/pnn/1.0.0/
  module Pnn
    # Check if a string is valid PNN notation
    #
    # @param pnn_string [String] the string to validate
    # @return [Boolean] true if valid PNN, false otherwise
    #
    # @example Validate PNN strings
    #   Sashite::Pnn.valid?("KING")     # => true
    #   Sashite::Pnn.valid?("queen")    # => true
    #   Sashite::Pnn.valid?("+ROOK")    # => true
    #   Sashite::Pnn.valid?("-pawn")    # => true
    #   Sashite::Pnn.valid?("King")     # => false (mixed case)
    #   Sashite::Pnn.valid?("KING1")    # => false (contains digit)
    def self.valid?(pnn_string)
      Name.valid?(pnn_string)
    end

    # Parse a PNN string into a Name object
    #
    # @param pnn_string [String] the piece name string
    # @return [Pnn::Name] a parsed name object
    # @raise [ArgumentError] if the name is invalid
    #
    # @example Parse valid PNN names
    #   Sashite::Pnn.parse("KING")    # => #<Pnn::Name value="KING">
    #   Sashite::Pnn.parse("+queen")  # => #<Pnn::Name value="+queen">
    def self.parse(pnn_string)
      Name.parse(pnn_string)
    end

    # Create a new Name instance directly
    #
    # @param value [String, Symbol] piece name to construct
    # @return [Pnn::Name] new name instance
    # @raise [ArgumentError] if name format is invalid
    #
    # @example
    #   Sashite::Pnn.name("BISHOP") # => #<Pnn::Name value="BISHOP">
    #   Sashite::Pnn.name(:queen)   # => #<Pnn::Name value="queen">
    def self.name(value)
      Name.new(value)
    end
  end
end
