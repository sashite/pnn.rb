# frozen_string_literal: true

module Sashite
  module Snn
    # Represents a style identifier in SNN format
    #
    # A style represents a particular tradition, variant, or design approach for game pieces.
    # The casing of the identifier determines player association:
    # - Uppercase identifiers belong to the first player
    # - Lowercase identifiers belong to the second player
    #
    # @example
    #   # First player styles (uppercase)
    #   chess_style = Sashite::Snn::Style.new("CHESS")
    #   shogi_style = Sashite::Snn::Style.new("SHOGI")
    #
    #   # Second player styles (lowercase)
    #   makruk_style = Sashite::Snn::Style.new("makruk")
    #   chess960_style = Sashite::Snn::Style.new("chess960")
    class Style
      # @return [String] The style identifier
      attr_reader :identifier

      # Create a new style instance
      #
      # @param identifier [String] The style identifier
      # @raise [ArgumentError] if the identifier is invalid SNN notation
      #
      # @example
      #   style = Sashite::Snn::Style.new("CHESS")
      #   # => #<Sashite::Snn::Style:0x... @identifier="CHESS">
      def initialize(identifier)
        raise ArgumentError, "Invalid SNN format: #{identifier.inspect}" unless Snn.valid?(identifier)

        @identifier = identifier.freeze

        freeze
      end

      # Parse a SNN string into a style object
      #
      # @param snn_string [String] The SNN string to parse
      # @return [Sashite::Snn::Style] A new style object
      # @raise [ArgumentError] if the string is invalid SNN notation
      #
      # @example
      #   style = Sashite::Snn::Style.parse("CHESS")
      #   # => #<Sashite::Snn::Style:0x... @identifier="CHESS">
      def self.parse(snn_string)
        new(snn_string)
      end

      # Check if this style belongs to the first player
      #
      # @return [Boolean] true if the style is uppercase (first player), false otherwise
      #
      # @example
      #   Sashite::Snn::Style.new("CHESS").first_player?  # => true
      #   Sashite::Snn::Style.new("shogi").first_player?  # => false
      def first_player?
        uppercase?
      end

      # Check if this style belongs to the second player
      #
      # @return [Boolean] true if the style is lowercase (second player), false otherwise
      #
      # @example
      #   Sashite::Snn::Style.new("CHESS").second_player?  # => false
      #   Sashite::Snn::Style.new("shogi").second_player?  # => true
      def second_player?
        lowercase?
      end

      # Check if the style identifier is uppercase
      #
      # @return [Boolean] true if the identifier is uppercase, false otherwise
      #
      # @example
      #   Sashite::Snn::Style.new("CHESS").uppercase?  # => true
      #   Sashite::Snn::Style.new("chess").uppercase?  # => false
      def uppercase?
        identifier == identifier.upcase
      end

      # Check if the style identifier is lowercase
      #
      # @return [Boolean] true if the identifier is lowercase, false otherwise
      #
      # @example
      #   Sashite::Snn::Style.new("CHESS").lowercase?  # => false
      #   Sashite::Snn::Style.new("chess").lowercase?  # => true
      def lowercase?
        identifier == identifier.downcase
      end

      # Convert the style to its string representation
      #
      # @return [String] The style identifier
      #
      # @example
      #   Sashite::Snn::Style.new("CHESS").to_s  # => "CHESS"
      def to_s
        identifier
      end

      # Convert the style to a symbol
      #
      # @return [Symbol] The style identifier as a symbol
      #
      # @example
      #   Sashite::Snn::Style.new("CHESS").to_sym  # => :CHESS
      def to_sym
        identifier.to_sym
      end

      # String representation for debugging
      #
      # @return [String] A detailed string representation
      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)} @identifier=#{identifier.inspect}>"
      end

      # Equality comparison
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] true if both objects are Style instances with the same identifier
      def ==(other)
        other.is_a?(Style) && identifier == other.identifier
      end

      # Alias for equality comparison
      alias eql? ==

      # Hash code for use in hashes and sets
      #
      # @return [Integer] The hash code
      def hash
        [self.class, identifier].hash
      end
    end
  end
end
