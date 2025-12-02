# frozen_string_literal: true

module Sashite
  module Pnn
    # Represents a piece name in PNN (Piece Name Notation) format.
    #
    # PNN provides a canonical naming system for abstract strategy game pieces.
    # Each name consists of an optional state modifier (+ or -) followed by a
    # case-consistent alphabetic name and an optional terminal marker (^),
    # encoding piece identity, player assignment, state, and terminal status
    # in a human-readable format.
    #
    # All instances are immutable.
    class Name
      # PNN validation pattern matching the specification
      PNN_PATTERN = /\A([+-]?)([A-Z]+|[a-z]+)(\^?)\z/

      # Error messages
      ERROR_INVALID_NAME = "Invalid PNN string: %s"

      # @return [String] the canonical piece name
      attr_reader :value

      # Create a new piece name instance
      #
      # @param name [String, Symbol] the piece name (e.g., "KING", :queen, "+ROOK", "-pawn", "KING^")
      # @raise [ArgumentError] if the name does not match PNN pattern
      def initialize(name)
        string_value = name.to_s
        self.class.validate_format(string_value)

        @value = string_value.freeze
        @parsed = parse_components(string_value)
        freeze
      end

      # Parse a PNN string into a Name object
      #
      # @param string [String] the PNN-formatted piece name
      # @return [Name] a new Name instance
      # @raise [ArgumentError] if the string is invalid
      #
      # @example
      #   Sashite::Pnn::Name.parse("KING")    # => #<Pnn::Name value="KING">
      #   Sashite::Pnn::Name.parse("+queen")  # => #<Pnn::Name value="+queen">
      #   Sashite::Pnn::Name.parse("KING^")   # => #<Pnn::Name value="KING^">
      #   Sashite::Pnn::Name.parse("+ROOK^")  # => #<Pnn::Name value="+ROOK^">
      def self.parse(string)
        new(string)
      end

      # Check whether the given string is a valid PNN name
      #
      # @param string [String] input string to validate
      # @return [Boolean] true if valid, false otherwise
      #
      # @example
      #   Sashite::Pnn::Name.valid?("KING")    # => true
      #   Sashite::Pnn::Name.valid?("King")    # => false (mixed case)
      #   Sashite::Pnn::Name.valid?("+queen")  # => true
      #   Sashite::Pnn::Name.valid?("KING^")   # => true
      #   Sashite::Pnn::Name.valid?("KING1")   # => false (contains digit)
      def self.valid?(string)
        string.is_a?(::String) && string.match?(PNN_PATTERN)
      end

      # Validate that the string is in proper PNN format
      #
      # @param str [String]
      # @raise [ArgumentError] if invalid
      def self.validate_format(str)
        raise ::ArgumentError, format(ERROR_INVALID_NAME, str.inspect) unless str.match?(PNN_PATTERN)
      end

      # Returns the string representation of the name
      #
      # @return [String]
      def to_s
        value
      end

      # Returns the base name without state modifier or terminal marker
      #
      # @return [String] the piece name without + or - prefix and without ^ suffix
      #
      # @example
      #   Sashite::Pnn::Name.parse("KING").base_name     # => "KING"
      #   Sashite::Pnn::Name.parse("+queen").base_name   # => "queen"
      #   Sashite::Pnn::Name.parse("-ROOK").base_name    # => "ROOK"
      #   Sashite::Pnn::Name.parse("KING^").base_name    # => "KING"
      #   Sashite::Pnn::Name.parse("+ROOK^").base_name   # => "ROOK"
      def base_name
        @parsed[:base_name]
      end

      # Check if the piece has enhanced state (+)
      #
      # @return [Boolean] true if enhanced, false otherwise
      #
      # @example
      #   Sashite::Pnn::Name.parse("+KING").enhanced?    # => true
      #   Sashite::Pnn::Name.parse("KING").enhanced?     # => false
      #   Sashite::Pnn::Name.parse("+KING^").enhanced?   # => true
      def enhanced?
        @parsed[:state_modifier] == "+"
      end

      # Check if the piece has diminished state (-)
      #
      # @return [Boolean] true if diminished, false otherwise
      #
      # @example
      #   Sashite::Pnn::Name.parse("-pawn").diminished?  # => true
      #   Sashite::Pnn::Name.parse("pawn").diminished?   # => false
      #   Sashite::Pnn::Name.parse("-pawn^").diminished? # => true
      def diminished?
        @parsed[:state_modifier] == "-"
      end

      # Check if the piece has normal state (no modifier)
      #
      # @return [Boolean] true if normal, false otherwise
      #
      # @example
      #   Sashite::Pnn::Name.parse("KING").normal?       # => true
      #   Sashite::Pnn::Name.parse("+KING").normal?      # => false
      #   Sashite::Pnn::Name.parse("KING^").normal?      # => true
      def normal?
        @parsed[:state_modifier].empty?
      end

      # Check if the piece is a terminal piece (has ^ marker)
      #
      # @return [Boolean] true if terminal, false otherwise
      #
      # @example
      #   Sashite::Pnn::Name.parse("KING^").terminal?    # => true
      #   Sashite::Pnn::Name.parse("KING").terminal?     # => false
      #   Sashite::Pnn::Name.parse("+KING^").terminal?   # => true
      #   Sashite::Pnn::Name.parse("-pawn^").terminal?   # => true
      def terminal?
        @parsed[:terminal_marker] == "^"
      end

      # Check if the piece belongs to the first player (uppercase)
      #
      # @return [Boolean] true if first player, false otherwise
      #
      # @example
      #   Sashite::Pnn::Name.parse("KING").first_player?     # => true
      #   Sashite::Pnn::Name.parse("queen").first_player?    # => false
      #   Sashite::Pnn::Name.parse("KING^").first_player?    # => true
      def first_player?
        @parsed[:base_name] == @parsed[:base_name].upcase
      end

      # Check if the piece belongs to the second player (lowercase)
      #
      # @return [Boolean] true if second player, false otherwise
      #
      # @example
      #   Sashite::Pnn::Name.parse("king").second_player?    # => true
      #   Sashite::Pnn::Name.parse("QUEEN").second_player?   # => false
      #   Sashite::Pnn::Name.parse("king^").second_player?   # => true
      def second_player?
        @parsed[:base_name] == @parsed[:base_name].downcase
      end

      # Check if another piece has the same base name (ignoring case, state, and terminal marker)
      #
      # @param other [Name] another piece name to compare
      # @return [Boolean] true if same base name, false otherwise
      #
      # @example
      #   king = Sashite::Pnn::Name.parse("KING")
      #   queen = Sashite::Pnn::Name.parse("king")
      #   enhanced = Sashite::Pnn::Name.parse("+KING")
      #   terminal = Sashite::Pnn::Name.parse("KING^")
      #
      #   king.same_base_name?(queen)     # => true (same piece, different player)
      #   king.same_base_name?(enhanced)  # => true (same piece, different state)
      #   king.same_base_name?(terminal)  # => true (same piece, terminal marker)
      def same_base_name?(other)
        return false unless other.is_a?(self.class)

        base_name.downcase == other.base_name.downcase
      end

      # Equality based on normalized string value
      #
      # @param other [Object]
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) && value == other.value
      end

      # Required for correct Set/hash behavior
      alias eql? ==

      # Hash based on class and value
      #
      # @return [Integer]
      def hash
        [self.class, value].hash
      end

      private

      # Parse the components of a PNN string
      #
      # @param str [String] the PNN string
      # @return [Hash] parsed components
      def parse_components(str)
        match = str.match(PNN_PATTERN)
        {
          state_modifier:  match[1],
          base_name:       match[2],
          terminal_marker: match[3]
        }
      end
    end
  end
end
