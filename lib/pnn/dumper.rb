# frozen_string_literal: true

module Pnn
  # Serializes piece components into PNN strings
  class Dumper
    # Valid prefix modifiers
    VALID_PREFIXES = ["+", "-", nil].freeze

    # Valid suffix modifiers
    VALID_SUFFIXES = ["'", nil].freeze

    # Letter validation pattern
    LETTER_PATTERN = /\A[a-zA-Z]\z/

    # Error messages
    ERROR_INVALID_LETTER = "Letter must be a single ASCII letter (a-z or A-Z): %s"
    ERROR_INVALID_PREFIX = "Invalid prefix: %s. Must be '+', '-', or nil."
    ERROR_INVALID_SUFFIX = "Invalid suffix: %s. Must be ''', or nil."

    # Serialize piece components into a PNN string
    #
    # @param letter [String] The single ASCII letter identifier
    # @param prefix [String, nil] Optional prefix modifier
    # @param suffix [String, nil] Optional suffix modifier
    # @return [String] PNN notation string
    # @raise [ArgumentError] If any component is invalid
    def self.dump(letter:, prefix: nil, suffix: nil)
      validate_letter(letter)
      validate_prefix(prefix)
      validate_suffix(suffix)

      "#{prefix}#{letter}#{suffix}"
    end

    # Validates that the letter is a single ASCII letter
    #
    # @param letter [Object] The letter to validate
    # @return [void]
    # @raise [ArgumentError] If the letter is invalid
    def self.validate_letter(letter)
      letter_str = String(letter)

      return if letter_str.match?(LETTER_PATTERN)

      raise ArgumentError, format(ERROR_INVALID_LETTER, letter_str)
    end

    # Validates that the prefix is valid
    #
    # @param prefix [String, nil] The prefix to validate
    # @return [void]
    # @raise [ArgumentError] If the prefix is invalid
    def self.validate_prefix(prefix)
      return if VALID_PREFIXES.include?(prefix)

      raise ArgumentError, format(ERROR_INVALID_PREFIX, prefix)
    end

    # Validates that the suffix is valid
    #
    # @param suffix [String, nil] The suffix to validate
    # @return [void]
    # @raise [ArgumentError] If the suffix is invalid
    def self.validate_suffix(suffix)
      return if VALID_SUFFIXES.include?(suffix)

      raise ArgumentError, format(ERROR_INVALID_SUFFIX, suffix)
    end

    private_class_method :validate_letter, :validate_prefix, :validate_suffix
  end
end
