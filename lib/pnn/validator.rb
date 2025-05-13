# frozen_string_literal: true

module Pnn
  # Validates PNN strings according to the specification
  class Validator
    # PNN validation pattern matching the JSON schema pattern in the spec
    PATTERN = /\A[-+]?[a-zA-Z][']?\z/

    # Class method to validate PNN strings
    #
    # @param pnn_string [Object] The PNN string to validate
    # @return [Boolean] True if the string is valid according to PNN specification
    def self.valid?(pnn_string)
      validate_string(String(pnn_string))
    end

    # Validates the given string against the PNN pattern
    #
    # @param string [String] The string to validate
    # @return [Boolean] True if the string matches the PNN pattern
    def self.validate_string(string)
      string.match?(PATTERN)
    end

    private_class_method :validate_string
  end
end
