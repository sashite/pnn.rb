# frozen_string_literal: true

require "sashite/pin"

module Sashite
  module Pnn
    # Represents a piece in PNN (Piece Name Notation) format.
    #
    # Extends PIN::Piece to add style awareness through derivation markers.
    # A PNN piece consists of a PIN string with an optional derivation suffix:
    # - No suffix: native style
    # - Apostrophe suffix ('): foreign style
    #
    # All instances are immutable - style manipulation methods return new instances.
    class Piece < ::Sashite::Pin::Piece
      # PNN validation pattern extending PIN
      PNN_PATTERN = /\A(?<prefix>[-+])?(?<letter>[a-zA-Z])(?<suffix>'?)\z/

      # Derivation marker for foreign style
      FOREIGN_SUFFIX = "'"

      # Error messages
      ERROR_INVALID_PNN = "Invalid PNN string: %s"
      ERROR_INVALID_NATIVE = "Native must be true or false: %s"

      # @return [Boolean] whether the piece has native style
      attr_reader :native
      alias native? native

      # Create a new piece instance with style information
      #
      # @param letter [String] single ASCII letter (a-z or A-Z)
      # @param native [Boolean] whether the piece has native style
      # @raise [ArgumentError] if parameters are invalid
      def initialize(letter, native: true, **)
        raise ::ArgumentError, format(ERROR_INVALID_NATIVE, native) unless [true, false].include?(native)

        @native = native
        super(letter, **)
      end

      # Parse a PNN string into a Piece object
      #
      # @param pnn_string [String] PNN notation string
      # @return [Piece] new piece instance
      # @raise [ArgumentError] if the PNN string is invalid
      # @example
      #   Pnn::Piece.parse("k")     # => #<Pnn::Piece letter="k" native=true>
      #   Pnn::Piece.parse("k'")    # => #<Pnn::Piece letter="k" native=false>
      #   Pnn::Piece.parse("+R'")   # => #<Pnn::Piece letter="R" enhanced=true native=false>
      def self.parse(pnn_string)
        string_value = String(pnn_string)
        matches = match_pattern(string_value)

        letter = matches[:letter]
        enhanced = matches[:prefix] == ENHANCED_PREFIX
        diminished = matches[:prefix] == DIMINISHED_PREFIX
        native = matches[:suffix] != FOREIGN_SUFFIX

        new(
          letter,
          native:     native,
          enhanced:   enhanced,
          diminished: diminished
        )
      end

      # Convert the piece to its PNN string representation
      #
      # @return [String] PNN notation string
      # @example
      #   piece.to_s  # => "k"
      #   piece.to_s  # => "k'"
      #   piece.to_s  # => "+R'"
      def to_s
        pin_string = super
        suffix = native? ? "" : FOREIGN_SUFFIX
        "#{pin_string}#{suffix}"
      end

      # Convert the piece to its underlying PIN representation
      #
      # @return [String] PIN notation string without style information
      def to_pin
        nativize.to_s
      end

      # Check if the piece has foreign style
      #
      # @return [Boolean] true if foreign style
      def foreign?
        !native?
      end

      # Create a new piece with native style
      #
      # @return [Piece] new piece instance with native style
      # @example
      #   piece.nativize  # k' => k
      def nativize
        return self if native?

        self.class.new(
          letter,
          native:     true,
          enhanced:   enhanced?,
          diminished: diminished?
        )
      end

      # Create a new piece with foreign style
      #
      # @return [Piece] new piece instance with foreign style
      # @example
      #   piece.foreignize  # k => k'
      def foreignize
        return self if foreign?

        self.class.new(
          letter,
          native:     false,
          enhanced:   enhanced?,
          diminished: diminished?
        )
      end

      # Create a new piece with toggled style
      #
      # @return [Piece] new piece instance with opposite style
      # @example
      #   piece.toggle_style  # k => k', k' => k
      def toggle_style
        native? ? foreignize : nativize
      end

      # Override parent methods to maintain PNN type in return values

      def enhance
        return self if enhanced?

        self.class.new(
          letter,
          native:     native?,
          enhanced:   true,
          diminished: false
        )
      end

      def unenhance
        return self unless enhanced?

        self.class.new(
          letter,
          native:     native?,
          enhanced:   false,
          diminished: diminished?
        )
      end

      def diminish
        return self if diminished?

        self.class.new(
          letter,
          native:     native?,
          enhanced:   false,
          diminished: true
        )
      end

      def undiminish
        return self unless diminished?

        self.class.new(
          letter,
          native:     native?,
          enhanced:   enhanced?,
          diminished: false
        )
      end

      def normalize
        return self if normal?

        self.class.new(
          letter,
          native: native?
        )
      end

      def flip
        flipped_letter = letter.swapcase

        self.class.new(
          flipped_letter,
          native:     native?,
          enhanced:   enhanced?,
          diminished: diminished?
        )
      end

      # Custom equality comparison including style
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if pieces are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        super && native? == other.native?
      end

      # Custom hash implementation including style
      #
      # @return [Integer] hash value
      def hash
        [super, @native].hash
      end

      # Match PNN pattern against string
      #
      # @param string [String] string to match
      # @return [MatchData] match data
      # @raise [ArgumentError] if string doesn't match
      def self.match_pattern(string)
        matches = PNN_PATTERN.match(string)
        return matches if matches

        raise ::ArgumentError, format(ERROR_INVALID_PNN, string)
      end

      private_class_method :match_pattern
    end
  end
end
