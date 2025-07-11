# frozen_string_literal: true

module Sashite
  module Snn
    # Represents a style name in SNN (Style Name Notation) format.
    #
    # SNN provides a canonical naming system for abstract strategy game styles.
    # Each name must start with an uppercase ASCII letter, followed by zero or more
    # lowercase letters or digits.
    #
    # All instances are immutable.
    class Name
      # SNN validation pattern matching the specification
      SNN_PATTERN = /\A[A-Z][a-z0-9]*\z/

      # Error messages
      ERROR_INVALID_NAME = "Invalid SNN string: %s"

      # @return [String] the canonical style name
      attr_reader :value

      # Create a new style name instance
      #
      # @param name [String, Symbol] the style name (e.g., "Shogi", :Chess960)
      # @raise [ArgumentError] if the name does not match SNN pattern
      def initialize(name)
        string_value = name.to_s
        self.class.validate_format(string_value)

        @value = string_value.freeze
        freeze
      end

      # Parse an SNN string into a Name object
      #
      # @param string [String] the SNN-formatted style name
      # @return [Name] a new Name instance
      # @raise [ArgumentError] if the string is invalid
      #
      # @example
      #   Sashite::Snn::Name.parse("Shogi") # => #<Snn::Name value="Shogi">
      def self.parse(string)
        new(string)
      end

      # Check whether the given string is a valid SNN name
      #
      # @param string [String] input string to validate
      # @return [Boolean] true if valid, false otherwise
      #
      # @example
      #   Sashite::Snn::Name.valid?("Chess")    # => true
      #   Sashite::Snn::Name.valid?("chess")    # => false
      def self.valid?(string)
        string.is_a?(::String) && string.match?(SNN_PATTERN)
      end

      # Returns the string representation of the name
      #
      # @return [String]
      def to_s
        value
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

      # Validate that the string is in proper SNN format
      #
      # @param str [String]
      # @raise [ArgumentError] if invalid
      def self.validate_format(str)
        raise ::ArgumentError, format(ERROR_INVALID_NAME, str.inspect) unless str.match?(SNN_PATTERN)
      end
    end
  end
end
