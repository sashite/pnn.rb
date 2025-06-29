# frozen_string_literal: true

require_relative "pnn/piece"

module Sashite
  # PNN (Piece Name Notation) implementation for Ruby
  #
  # Extends PIN to provide style-aware piece representation in abstract strategy board games.
  # PNN adds a derivation marker that distinguishes pieces by their style origin, enabling
  # cross-style game scenarios and piece origin tracking.
  #
  # Format: <pin>[<suffix>]
  # - PIN component: [<state>]<letter> (state modifier + letter)
  # - Suffix: "'" for foreign style, none for native style
  #
  # Examples:
  #   "K"   - First player king (native style)
  #   "K'"  - First player king (foreign style)
  #   "+R"  - First player rook, enhanced state (native style)
  #   "+R'" - First player rook, enhanced state (foreign style)
  #   "-p'" - Second player pawn, diminished state (foreign style)
  #
  # See: https://sashite.dev/specs/pnn/1.0.0/
  module Pnn
    # Regular expression for PNN validation
    # Matches: optional state modifier, letter, optional derivation marker
    PNN_REGEX = /\A[-+]?[A-Za-z]'?\z/

    # Check if a string is a valid PNN notation
    #
    # @param pnn [String] The string to validate
    # @return [Boolean] true if valid PNN, false otherwise
    #
    # @example
    #   Sashite::Pnn.valid?("K")    # => true
    #   Sashite::Pnn.valid?("K'")   # => true
    #   Sashite::Pnn.valid?("+R'")  # => true
    #   Sashite::Pnn.valid?("-p'")  # => true
    #   Sashite::Pnn.valid?("K''")  # => false
    #   Sashite::Pnn.valid?("++K'") # => false
    def self.valid?(pnn)
      return false unless pnn.is_a?(::String)

      pnn.match?(PNN_REGEX)
    end

    # Parse a PNN string into a Piece object
    #
    # @param pnn_string [String] PNN notation string
    # @return [Pnn::Piece] new piece instance
    # @raise [ArgumentError] if the PNN string is invalid
    # @example
    #   Sashite::Pnn.parse("K")     # => #<Pnn::Piece letter="K" native=true>
    #   Sashite::Pnn.parse("K'")    # => #<Pnn::Piece letter="K" native=false>
    #   Sashite::Pnn.parse("+R'")   # => #<Pnn::Piece letter="R" enhanced=true native=false>
    def self.parse(pnn_string)
      Piece.parse(pnn_string)
    end
  end
end
