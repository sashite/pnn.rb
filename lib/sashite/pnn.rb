# frozen_string_literal: true

require_relative "pnn/piece"

module Sashite
  # PNN (Piece Name Notation) implementation for Ruby
  #
  # Provides style-aware ASCII-based format for representing pieces in abstract strategy board games.
  # PNN extends PIN by adding derivation markers that distinguish pieces by their style origin,
  # enabling cross-style game scenarios and piece origin tracking.
  #
  # Format: [<state>]<letter>[<derivation>]
  # - State modifier: "+" (enhanced), "-" (diminished), or none (normal)
  # - Letter: A-Z (first player), a-z (second player)
  # - Derivation marker: "'" (foreign style), or none (native style)
  #
  # Examples:
  #   "K"   - First player king (native style, normal state)
  #   "k'"  - Second player king (foreign style, normal state)
  #   "+R'" - First player rook (foreign style, enhanced state)
  #   "-p"  - Second player pawn (native style, diminished state)
  #
  # See: https://sashite.dev/specs/pnn/1.0.0/
  module Pnn
    # Check if a string is a valid PNN notation
    #
    # @param pnn_string [String] The string to validate
    # @return [Boolean] true if valid PNN, false otherwise
    #
    # @example
    #   Sashite::Pnn.valid?("K")     # => true
    #   Sashite::Pnn.valid?("+R'")   # => true
    #   Sashite::Pnn.valid?("-p")    # => true
    #   Sashite::Pnn.valid?("KK")    # => false
    #   Sashite::Pnn.valid?("++K")   # => false
    def self.valid?(pnn_string)
      Piece.valid?(pnn_string)
    end

    # Parse a PNN string into a Piece object
    #
    # @param pnn_string [String] PNN notation string
    # @return [Pnn::Piece] new piece instance
    # @raise [ArgumentError] if the PNN string is invalid
    # @example
    #   Sashite::Pnn.parse("K")     # => #<Pnn::Piece type=:K side=:first state=:normal native=true>
    #   Sashite::Pnn.parse("+R'")   # => #<Pnn::Piece type=:R side=:first state=:enhanced native=false>
    #   Sashite::Pnn.parse("-p")    # => #<Pnn::Piece type=:P side=:second state=:diminished native=true>
    def self.parse(pnn_string)
      Piece.parse(pnn_string)
    end

    # Create a new piece instance
    #
    # @param type [Symbol] piece type (:A to :Z)
    # @param side [Symbol] player side (:first or :second)
    # @param state [Symbol] piece state (:normal, :enhanced, or :diminished)
    # @param native [Boolean] style derivation (true for native, false for foreign)
    # @return [Pnn::Piece] new piece instance
    # @raise [ArgumentError] if parameters are invalid
    # @example
    #   Sashite::Pnn.piece(:K, :first, :normal, true)      # => #<Pnn::Piece type=:K side=:first state=:normal native=true>
    #   Sashite::Pnn.piece(:R, :first, :enhanced, false)   # => #<Pnn::Piece type=:R side=:first state=:enhanced native=false>
    #   Sashite::Pnn.piece(:P, :second, :diminished, true) # => #<Pnn::Piece type=:P side=:second state=:diminished native=true>
    def self.piece(type, side, state = Sashite::Pin::Piece::NORMAL_STATE, native = Piece::NATIVE)
      Piece.new(type, side, state, native)
    end
  end
end
