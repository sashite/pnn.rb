# frozen_string_literal: true

require "sashite/pin"

module Sashite
  module Pnn
    # Represents a piece in PNN (Piece Name Notation) format.
    #
    # A piece consists of a PIN component with an optional derivation marker:
    # - PIN component: [<state>]<letter> (from PIN specification)
    # - Derivation marker: "'" (foreign style) or none (native style)
    #
    # The case of the letter determines ownership:
    # - Uppercase (A-Z): first player
    # - Lowercase (a-z): second player
    #
    # Style derivation logic:
    # - No suffix: piece has the native style of its current side
    # - Apostrophe suffix: piece has the foreign style (opposite side's native style)
    #
    # All instances are immutable - state manipulation methods return new instances.
    # This extends the Game Protocol's piece model with Style support through derivation.
    class Piece
      # PNN validation pattern matching the specification
      PNN_PATTERN = /\A(?<prefix>[-+])?(?<letter>[a-zA-Z])(?<suffix>')?\z/

      # Valid derivation suffixes
      FOREIGN_SUFFIX = "'"
      NATIVE_SUFFIX = ""

      # Derivation constants
      NATIVE = true
      FOREIGN = false

      # Valid derivations
      VALID_DERIVATIONS = [NATIVE, FOREIGN].freeze

      # Error messages
      ERROR_INVALID_PNN = "Invalid PNN string: %s"
      ERROR_INVALID_DERIVATION = "Derivation must be true (native) or false (foreign), got: %s"

      # @return [Symbol] the piece type (:A to :Z)
      def type
        @piece.type
      end

      # @return [Symbol] the player side (:first or :second)
      def side
        @piece.side
      end

      # @return [Symbol] the piece state (:normal, :enhanced, or :diminished)
      def state
        @piece.state
      end

      # @return [Boolean] the style derivation (true for native, false for foreign)
      attr_reader :native

      # Create a new piece instance
      #
      # @param type [Symbol] piece type (:A to :Z)
      # @param side [Symbol] player side (:first or :second)
      # @param state [Symbol] piece state (:normal, :enhanced, or :diminished)
      # @param native [Boolean] style derivation (true for native, false for foreign)
      # @raise [ArgumentError] if parameters are invalid
      # @example
      #   Piece.new(:K, :first, :normal, true)
      #   Piece.new(:P, :second, :enhanced, false)
      def initialize(type, side, state = Sashite::Pin::Piece::NORMAL_STATE, native = NATIVE)
        # Validate using PIN class methods for type, side, and state
        Sashite::Pin::Piece.validate_type(type)
        Sashite::Pin::Piece.validate_side(side)
        Sashite::Pin::Piece.validate_state(state)
        self.class.validate_derivation(native)

        @piece = Sashite::Pin::Piece.new(type, side, state)
        @native = native

        freeze
      end

      # Parse a PNN string into a Piece object
      #
      # @param pnn_string [String] PNN notation string
      # @return [Piece] new piece instance
      # @raise [ArgumentError] if the PNN string is invalid
      # @example
      #   Pnn::Piece.parse("k")     # => #<Pnn::Piece type=:K side=:second state=:normal native=true>
      #   Pnn::Piece.parse("+R'")   # => #<Pnn::Piece type=:R side=:first state=:enhanced native=false>
      #   Pnn::Piece.parse("-p")    # => #<Pnn::Piece type=:P side=:second state=:diminished native=true>
      def self.parse(pnn_string)
        string_value = String(pnn_string)
        matches = match_pattern(string_value)

        letter = matches[:letter]
        enhanced = matches[:prefix] == Sashite::Pin::Piece::ENHANCED_PREFIX
        diminished = matches[:prefix] == Sashite::Pin::Piece::DIMINISHED_PREFIX
        foreign = matches[:suffix] == FOREIGN_SUFFIX

        # Extract type and side from letter
        piece_type = letter.upcase.to_sym
        piece_side = letter == letter.upcase ? Sashite::Pin::Piece::FIRST_PLAYER : Sashite::Pin::Piece::SECOND_PLAYER
        piece_state = if enhanced
                        Sashite::Pin::Piece::ENHANCED_STATE
                      elsif diminished
                        Sashite::Pin::Piece::DIMINISHED_STATE
                      else
                        Sashite::Pin::Piece::NORMAL_STATE
                      end
        piece_native = !foreign

        new(piece_type, piece_side, piece_state, piece_native)
      end

      # Check if a string is a valid PNN notation
      #
      # @param pnn_string [String] The string to validate
      # @return [Boolean] true if valid PNN, false otherwise
      #
      # @example
      #   Sashite::Pnn::Piece.valid?("K")    # => true
      #   Sashite::Pnn::Piece.valid?("+R'")  # => true
      #   Sashite::Pnn::Piece.valid?("-p")   # => true
      #   Sashite::Pnn::Piece.valid?("KK")   # => false
      #   Sashite::Pnn::Piece.valid?("++K")  # => false
      def self.valid?(pnn_string)
        return false unless pnn_string.is_a?(::String)

        pnn_string.match?(PNN_PATTERN)
      end

      # Convert the piece to its PNN string representation
      #
      # @return [String] PNN notation string
      # @example
      #   piece.to_s  # => "+R'"
      #   piece.to_s  # => "-p"
      #   piece.to_s  # => "K"
      def to_s
        "#{prefix}#{letter}#{suffix}"
      end

      # Get the letter representation (inherited from PIN logic)
      #
      # @return [String] letter representation combining type and side
      def letter
        @piece.letter
      end

      # Get the prefix representation (inherited from PIN logic)
      #
      # @return [String] prefix representing the state
      def prefix
        @piece.prefix
      end

      # Get the suffix representation
      #
      # @return [String] suffix representing the derivation
      def suffix
        native? ? NATIVE_SUFFIX : FOREIGN_SUFFIX
      end

      # Create a new piece with enhanced state
      #
      # @return [Piece] new piece instance with enhanced state
      # @example
      #   piece.enhance  # (:K, :first, :normal, true) => (:K, :first, :enhanced, true)
      def enhance
        return self if enhanced?

        self.class.new(type, side, Sashite::Pin::Piece::ENHANCED_STATE, native)
      end

      # Create a new piece without enhanced state
      #
      # @return [Piece] new piece instance without enhanced state
      # @example
      #   piece.unenhance  # (:K, :first, :enhanced, true) => (:K, :first, :normal, true)
      def unenhance
        return self unless enhanced?

        self.class.new(type, side, Sashite::Pin::Piece::NORMAL_STATE, native)
      end

      # Create a new piece with diminished state
      #
      # @return [Piece] new piece instance with diminished state
      # @example
      #   piece.diminish  # (:K, :first, :normal, true) => (:K, :first, :diminished, true)
      def diminish
        return self if diminished?

        self.class.new(type, side, Sashite::Pin::Piece::DIMINISHED_STATE, native)
      end

      # Create a new piece without diminished state
      #
      # @return [Piece] new piece instance without diminished state
      # @example
      #   piece.undiminish  # (:K, :first, :diminished, true) => (:K, :first, :normal, true)
      def undiminish
        return self unless diminished?

        self.class.new(type, side, Sashite::Pin::Piece::NORMAL_STATE, native)
      end

      # Create a new piece with normal state (no modifiers)
      #
      # @return [Piece] new piece instance with normal state
      # @example
      #   piece.normalize  # (:K, :first, :enhanced, true) => (:K, :first, :normal, true)
      def normalize
        return self if normal?

        self.class.new(type, side, Sashite::Pin::Piece::NORMAL_STATE, native)
      end

      # Create a new piece with opposite side
      #
      # @return [Piece] new piece instance with opposite side
      # @example
      #   piece.flip  # (:K, :first, :normal, true) => (:K, :second, :normal, true)
      def flip
        self.class.new(type, opposite_side, state, native)
      end

      # Create a new piece with foreign style (derivation marker)
      #
      # @return [Piece] new piece instance with foreign style
      # @example
      #   piece.derive  # (:K, :first, :normal, true) => (:K, :first, :normal, false)
      def derive
        return self if derived?

        self.class.new(type, side, state, FOREIGN)
      end

      # Create a new piece with native style (no derivation marker)
      #
      # @return [Piece] new piece instance with native style
      # @example
      #   piece.underive  # (:K, :first, :normal, false) => (:K, :first, :normal, true)
      def underive
        return self if native?

        self.class.new(type, side, state, NATIVE)
      end

      # Create a new piece with a different type (keeping same side, state, and derivation)
      #
      # @param new_type [Symbol] new type (:A to :Z)
      # @return [Piece] new piece instance with different type
      # @example
      #   piece.with_type(:Q)  # (:K, :first, :normal, true) => (:Q, :first, :normal, true)
      def with_type(new_type)
        Sashite::Pin::Piece.validate_type(new_type)
        return self if type == new_type

        self.class.new(new_type, side, state, native)
      end

      # Create a new piece with a different side (keeping same type, state, and derivation)
      #
      # @param new_side [Symbol] :first or :second
      # @return [Piece] new piece instance with different side
      # @example
      #   piece.with_side(:second)  # (:K, :first, :normal, true) => (:K, :second, :normal, true)
      def with_side(new_side)
        Sashite::Pin::Piece.validate_side(new_side)
        return self if side == new_side

        self.class.new(type, new_side, state, native)
      end

      # Create a new piece with a different state (keeping same type, side, and derivation)
      #
      # @param new_state [Symbol] :normal, :enhanced, or :diminished
      # @return [Piece] new piece instance with different state
      # @example
      #   piece.with_state(:enhanced)  # (:K, :first, :normal, true) => (:K, :first, :enhanced, true)
      def with_state(new_state)
        Sashite::Pin::Piece.validate_state(new_state)
        return self if state == new_state

        self.class.new(type, side, new_state, native)
      end

      # Create a new piece with a different derivation (keeping same type, side, and state)
      #
      # @param new_native [Boolean] true for native, false for foreign
      # @return [Piece] new piece instance with different derivation
      # @example
      #   piece.with_derivation(false)  # (:K, :first, :normal, true) => (:K, :first, :normal, false)
      def with_derivation(new_native)
        self.class.validate_derivation(new_native)
        return self if native == new_native

        self.class.new(type, side, state, new_native)
      end

      # Check if the piece has enhanced state
      #
      # @return [Boolean] true if enhanced
      def enhanced?
        @piece.enhanced?
      end

      # Check if the piece has diminished state
      #
      # @return [Boolean] true if diminished
      def diminished?
        @piece.diminished?
      end

      # Check if the piece has normal state (no modifiers)
      #
      # @return [Boolean] true if no modifiers are present
      def normal?
        @piece.normal?
      end

      # Check if the piece belongs to the first player
      #
      # @return [Boolean] true if first player
      def first_player?
        @piece.first_player?
      end

      # Check if the piece belongs to the second player
      #
      # @return [Boolean] true if second player
      def second_player?
        @piece.second_player?
      end

      # Check if the piece has native style (no derivation marker)
      #
      # @return [Boolean] true if native style
      def native?
        native == NATIVE
      end

      # Check if the piece has foreign style (derivation marker)
      #
      # @return [Boolean] true if foreign style
      def derived?
        native == FOREIGN
      end

      # Alias for derived? to match the specification terminology
      alias foreign? derived?

      # Check if this piece is the same type as another (ignoring side, state, and derivation)
      #
      # @param other [Piece] piece to compare with
      # @return [Boolean] true if same type
      # @example
      #   king1.same_type?(king2)  # (:K, :first, :normal, true) and (:K, :second, :enhanced, false) => true
      def same_type?(other)
        return false unless other.is_a?(self.class)

        @piece.same_type?(other.instance_variable_get(:@piece))
      end

      # Check if this piece belongs to the same side as another
      #
      # @param other [Piece] piece to compare with
      # @return [Boolean] true if same side
      def same_side?(other)
        return false unless other.is_a?(self.class)

        @piece.same_side?(other.instance_variable_get(:@piece))
      end

      # Check if this piece has the same state as another
      #
      # @param other [Piece] piece to compare with
      # @return [Boolean] true if same state
      def same_state?(other)
        return false unless other.is_a?(self.class)

        @piece.same_state?(other.instance_variable_get(:@piece))
      end

      # Check if this piece has the same style derivation as another
      #
      # @param other [Piece] piece to compare with
      # @return [Boolean] true if same style derivation
      def same_style?(other)
        return false unless other.is_a?(self.class)

        native == other.native
      end

      # Custom equality comparison
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if pieces are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        @piece == other.instance_variable_get(:@piece) && native == other.native
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value
      def hash
        [self.class, @piece, native].hash
      end

      # Validate that the derivation is a valid boolean
      #
      # @param derivation [Boolean] the derivation to validate
      # @raise [ArgumentError] if invalid
      def self.validate_derivation(derivation)
        return if VALID_DERIVATIONS.include?(derivation)

        raise ::ArgumentError, format(ERROR_INVALID_DERIVATION, derivation.inspect)
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

      private

      # Get the opposite side of the current piece
      #
      # @return [Symbol] :first if current side is :second, :second if current side is :first
      def opposite_side
        @piece.send(:opposite_side)
      end
    end
  end
end
