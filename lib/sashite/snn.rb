# frozen_string_literal: true

require_relative "snn/style"

module Sashite
  # Style Name Notation (SNN) module
  #
  # SNN provides a consistent and rule-agnostic format for identifying piece styles
  # in abstract strategy board games. It enables clear distinction between different
  # piece traditions, variants, or design approaches within multi-style gaming environments.
  #
  # @see https://sashite.dev/documents/snn/1.0.0/ SNN Specification v1.0.0
  module Snn
    # SNN validation regular expression
    # Matches: uppercase style (A-Z followed by A-Z0-9*) or lowercase style (a-z followed by a-z0-9*)
    VALIDATION_REGEX = /\A([A-Z][A-Z0-9]*|[a-z][a-z0-9]*)\z/

    # Check if a string is valid SNN notation
    #
    # @param snn_string [String] The string to validate
    # @return [Boolean] true if the string is valid SNN notation, false otherwise
    #
    # @example
    #   Sashite::Snn.valid?("CHESS")      # => true
    #   Sashite::Snn.valid?("shogi")      # => true
    #   Sashite::Snn.valid?("Chess")      # => false (mixed case)
    #   Sashite::Snn.valid?("123")        # => false (must start with letter)
    #   Sashite::Snn.valid?("")           # => false (empty string)
    def self.valid?(snn_string)
      return false unless snn_string.is_a?(String)
      return false if snn_string.empty?

      VALIDATION_REGEX.match?(snn_string)
    end

    # Convenience method to create a style object
    #
    # @param identifier [String] The style identifier
    # @return [Sashite::Snn::Style] A new style object
    # @raise [ArgumentError] if the identifier is invalid
    #
    # @example
    #   style = Sashite::Snn.style("CHESS")
    #   # => #<Sashite::Snn::Style:0x... @identifier="CHESS">
    def self.style(identifier)
      Style.new(identifier)
    end
  end
end
