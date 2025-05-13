# frozen_string_literal: true

module Pnn
  # Serializes piece components into PNN strings
  class Dumper
    # Valid prefix modifiers
    VALID_PREFIXES = ["+", "-", nil].freeze

    # Valid suffix modifiers
    VALID_SUFFIXES = ["'", nil].freeze

    # Serialize piece components into a PNN string
    #
    # @param letter [String] The single ASCII letter identifier
    # @param prefix [String, nil] Optional prefix modifier
    # @param suffix [String, nil] Optional suffix modifier
    # @return [String] PNN notation string
    # @raise [ArgumentError] If any component is invalid
    def self.dump(letter:, prefix: nil, suffix: nil)
      letter = String(letter)

      unless letter.match?(/^[a-zA-Z]$/)
        raise ArgumentError, "Letter must be a single ASCII letter (a-z or A-Z): #{letter}"
      end

      raise ArgumentError, "Invalid prefix: #{prefix}. Must be '+', '-', or nil." unless VALID_PREFIXES.include?(prefix)

      raise ArgumentError, "Invalid suffix: #{suffix}. Must be ''', or nil." unless VALID_SUFFIXES.include?(suffix)

      "#{prefix}#{letter}#{suffix}"
    end
  end
end
