# frozen_string_literal: true

module Pnn
  # Validates PNN strings according to the specification
  class Validator
    # PNN validation pattern matching the JSON schema pattern in the spec
    PATTERN = /\A[-+]?[a-zA-Z][=<>]?\z/

    # Class method to validate PNN strings
    #
    # @param pnn_string [String] The PNN string to validate
    # @return [Boolean] True if the string is valid according to PNN specification
    def self.valid?(pnn_string)
      String(pnn_string).match?(PATTERN)
    end
  end
end
