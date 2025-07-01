# frozen_string_literal: true

module Sashite
  module Snn
    # Represents a style in SNN (Style Name Notation) format.
    #
    # A style consists of an alphanumeric identifier with case-based side encoding:
    # - Uppercase identifier: first player (CHESS, SHOGI, XIANGQI)
    # - Lowercase identifier: second player (chess, shogi, xiangqi)
    #
    # All instances are immutable - transformation methods return new instances.
    # This follows the Game Protocol's style model with Name and Side attributes.
    class Style
      # SNN validation pattern matching the specification
      SNN_PATTERN = /\A(?<identifier>[A-Z][A-Z0-9]*|[a-z][a-z0-9]*)\z/

      # Pattern for proper name capitalization (first letter uppercase, rest lowercase/digits)
      PROPER_NAME_PATTERN = /\A[A-Z][a-z0-9]*\z/

      # Player side constants
      FIRST_PLAYER = :first
      SECOND_PLAYER = :second

      # Valid sides
      VALID_SIDES = [FIRST_PLAYER, SECOND_PLAYER].freeze

      # Error messages
      ERROR_INVALID_SNN = "Invalid SNN string: %s"
      ERROR_INVALID_NAME = "Name must be a symbol with proper capitalization (first letter uppercase, rest lowercase), got: %s"
      ERROR_INVALID_SIDE = "Side must be :first or :second, got: %s"

      # @return [Symbol] the style name (with proper capitalization)
      attr_reader :name

      # @return [Symbol] the player side (:first or :second)
      attr_reader :side

      # Create a new style instance
      #
      # @param name [Symbol] style name (with proper capitalization)
      # @param side [Symbol] player side (:first or :second)
      # @raise [ArgumentError] if parameters are invalid
      def initialize(name, side)
        self.class.validate_name(name)
        self.class.validate_side(side)

        @name = name
        @side = side

        freeze
      end

      # Parse an SNN string into a Style object
      #
      # @param snn_string [String] SNN notation string
      # @return [Style] new style instance
      # @raise [ArgumentError] if the SNN string is invalid
      # @example
      #   Snn::Style.parse("CHESS")     # => #<Snn::Style name=:Chess side=:first>
      #   Snn::Style.parse("chess")     # => #<Snn::Style name=:Chess side=:second>
      #   Snn::Style.parse("SHOGI")     # => #<Snn::Style name=:Shogi side=:first>
      def self.parse(snn_string)
        string_value = String(snn_string)
        matches = match_pattern(string_value)

        identifier = matches[:identifier]

        # Determine side from case
        style_side = identifier == identifier.upcase ? FIRST_PLAYER : SECOND_PLAYER

        # Normalize name to proper capitalization
        style_name = normalize_name(identifier)

        new(style_name, style_side)
      end

      # Convert the style to its SNN string representation
      #
      # @return [String] SNN notation string
      # @example
      #   style.to_s  # => "CHESS"
      #   style.to_s  # => "chess"
      #   style.to_s  # => "SHOGI"
      def to_s
        first_player? ? name.to_s.upcase : name.to_s.downcase
      end

      # Create a new style with opposite ownership (side)
      #
      # @return [Style] new style instance with flipped side
      # @example
      #   style.flip  # (:Chess, :first) => (:Chess, :second)
      def flip
        self.class.new(name, opposite_side)
      end

      # Create a new style with a different name (keeping same side)
      #
      # @param new_name [Symbol] new name (with proper capitalization)
      # @return [Style] new style instance with different name
      # @example
      #   style.with_name(:Shogi)  # (:Chess, :first) => (:Shogi, :first)
      def with_name(new_name)
        self.class.validate_name(new_name)
        return self if name == new_name

        self.class.new(new_name, side)
      end

      # Create a new style with a different side (keeping same name)
      #
      # @param new_side [Symbol] :first or :second
      # @return [Style] new style instance with different side
      # @example
      #   style.with_side(:second)  # (:Chess, :first) => (:Chess, :second)
      def with_side(new_side)
        self.class.validate_side(new_side)
        return self if side == new_side

        self.class.new(name, new_side)
      end

      # Check if the style belongs to the first player
      #
      # @return [Boolean] true if first player
      def first_player?
        side == FIRST_PLAYER
      end

      # Check if the style belongs to the second player
      #
      # @return [Boolean] true if second player
      def second_player?
        side == SECOND_PLAYER
      end

      # Check if this style has the same name as another
      #
      # @param other [Style] style to compare with
      # @return [Boolean] true if same name
      # @example
      #   chess1.same_name?(chess2)  # (:Chess, :first) and (:Chess, :second) => true
      def same_name?(other)
        return false unless other.is_a?(self.class)

        name == other.name
      end

      # Check if this style belongs to the same side as another
      #
      # @param other [Style] style to compare with
      # @return [Boolean] true if same side
      def same_side?(other)
        return false unless other.is_a?(self.class)

        side == other.side
      end

      # Custom equality comparison
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if styles are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        name == other.name && side == other.side
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value
      def hash
        [self.class, name, side].hash
      end

      # Validate that the name is a valid symbol with proper capitalization
      #
      # @param name [Symbol] the name to validate
      # @raise [ArgumentError] if invalid
      def self.validate_name(name)
        return if valid_name?(name)

        raise ::ArgumentError, format(ERROR_INVALID_NAME, name.inspect)
      end

      # Validate that the side is a valid symbol
      #
      # @param side [Symbol] the side to validate
      # @raise [ArgumentError] if invalid
      def self.validate_side(side)
        return if VALID_SIDES.include?(side)

        raise ::ArgumentError, format(ERROR_INVALID_SIDE, side.inspect)
      end

      # Check if a name is valid (symbol with proper capitalization)
      #
      # @param name [Object] the name to check
      # @return [Boolean] true if valid
      def self.valid_name?(name)
        return false unless name.is_a?(::Symbol)

        name_string = name.to_s
        return false if name_string.empty?

        # Must match proper capitalization pattern
        name_string.match?(PROPER_NAME_PATTERN)
      end

      # Normalize identifier to proper capitalization symbol
      #
      # @param identifier [String] the identifier to normalize
      # @return [Symbol] normalized name symbol
      def self.normalize_name(identifier)
        # Convert to proper capitalization: first letter uppercase, rest lowercase
        normalized = identifier.downcase
        normalized[0] = normalized[0].upcase if normalized.length > 0
        normalized.to_sym
      end

      # Match SNN pattern against string
      #
      # @param string [String] string to match
      # @return [MatchData] match data
      # @raise [ArgumentError] if string doesn't match
      def self.match_pattern(string)
        matches = SNN_PATTERN.match(string)
        return matches if matches

        raise ::ArgumentError, format(ERROR_INVALID_SNN, string)
      end

      private_class_method :valid_name?, :normalize_name, :match_pattern

      private

      # Get the opposite side
      #
      # @return [Symbol] the opposite side
      def opposite_side
        first_player? ? SECOND_PLAYER : FIRST_PLAYER
      end
    end
  end
end
