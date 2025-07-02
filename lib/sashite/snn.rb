# frozen_string_literal: true

require_relative "snn/style"

module Sashite
  # SNN (Style Name Notation) implementation for Ruby
  #
  # Provides a rule-agnostic format for identifying styles in abstract strategy board games.
  # SNN uses standardized naming conventions with case-based side encoding, enabling clear
  # distinction between different traditions in multi-style gaming environments.
  #
  # Format: <style-identifier>
  # - Uppercase identifier: First player styles (CHESS, SHOGI, XIANGQI)
  # - Lowercase identifier: Second player styles (chess, shogi, xiangqi)
  # - Case consistency: Entire identifier must be uppercase or lowercase
  #
  # Examples:
  #   "CHESS"  - First player chess style
  #   "chess"  - Second player chess style
  #   "SHOGI"  - First player shōgi style
  #   "shogi"  - Second player shōgi style
  #
  # See: https://sashite.dev/specs/snn/1.0.0/
  module Snn
    # Check if a string is a valid SNN notation
    #
    # @param snn_string [String] the string to validate
    # @return [Boolean] true if valid SNN, false otherwise
    #
    # @example Validate various SNN formats
    #   Sashite::Snn.valid?("CHESS") # => true
    #   Sashite::Snn.valid?("Chess") # => false
    def self.valid?(snn_string)
      Style.valid?(snn_string)
    end

    # Parse an SNN string into a Style object
    #
    # @param snn_string [String] SNN notation string
    # @return [Snn::Style] parsed style object with name and side attributes
    # @raise [ArgumentError] if the SNN string is invalid
    # @example Parse different SNN formats
    #   Sashite::Snn.parse("CHESS") # => #<Snn::Style name=:Chess side=:first>
    #   Sashite::Snn.parse("chess") # => #<Snn::Style name=:Chess side=:second>
    #   Sashite::Snn.parse("SHOGI") # => #<Snn::Style name=:Shogi side=:first>
    def self.parse(snn_string)
      Style.parse(snn_string)
    end

    # Create a new style instance
    #
    # @param name [Symbol] style name (with proper capitalization)
    # @param side [Symbol] player side (:first or :second)
    # @return [Snn::Style] new immutable style instance
    # @raise [ArgumentError] if parameters are invalid
    # @example Create styles directly
    #   Sashite::Snn.style(:Chess, :first)  # => #<Snn::Style name=:Chess side=:first>
    #   Sashite::Snn.style(:Shogi, :second) # => #<Snn::Style name=:Shogi side=:second>
    def self.style(name, side)
      Style.new(name, side)
    end
  end
end
