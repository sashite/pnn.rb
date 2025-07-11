# frozen_string_literal: true

require_relative "snn/name"

module Sashite
  # SNN (Style Name Notation) implementation for Ruby
  #
  # Provides a formal naming system for identifying styles in abstract strategy board games.
  # SNN uses canonical, human-readable ASCII names beginning with an uppercase letter.
  # It supports unlimited unique style identifiers with consistent, rule-agnostic semantics.
  #
  # Format: <uppercase-letter>[<lowercase-letter | digit>]*
  #
  # Examples:
  #   "Chess"       - Standard Western chess
  #   "Shogi"       - Japanese chess
  #   "Minishogi"   - 5×5 compact shōgi variant
  #   "Chess960"    - Fischer random chess
  #
  # See: https://sashite.dev/specs/snn/1.0.0/
  module Snn
    # Check if a string is valid SNN notation
    #
    # @param snn_string [String] the string to validate
    # @return [Boolean] true if valid SNN, false otherwise
    #
    # @example Validate SNN strings
    #   Sashite::Snn.valid?("Chess")     # => true
    #   Sashite::Snn.valid?("minishogi") # => false
    #   Sashite::Snn.valid?("Go9x9")     # => true
    def self.valid?(snn_string)
      Name.valid?(snn_string)
    end

    # Parse an SNN string into a Name object
    #
    # @param snn_string [String] the name string
    # @return [Snn::Name] a parsed name object
    # @raise [ArgumentError] if the name is invalid
    #
    # @example Parse valid SNN names
    #   Sashite::Snn.parse("Shogi")    # => #<Snn::Name value="Shogi">
    def self.parse(snn_string)
      Name.parse(snn_string)
    end

    # Create a new Name instance directly
    #
    # @param value [String, Symbol] style name to construct
    # @return [Snn::Name] new name instance
    # @raise [ArgumentError] if name format is invalid
    #
    # @example
    #   Sashite::Snn.name("Xiangqi") # => #<Snn::Name value="Xiangqi">
    def self.name(value)
      Name.new(value)
    end
  end
end
