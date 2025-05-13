# frozen_string_literal: true

module Pnn
  # Parses PNN strings into their component parts
  class Parser
    # PNN regex capture groups for parsing
    PATTERN = /\A(?<prefix>[-+])?(?<letter>[a-zA-Z])(?<suffix>['])?\z/

    # Parse a PNN string into its components
    #
    # @param pnn_string [String] The PNN string to parse
    # @return [Hash] Hash containing the parsed components
    # @raise [ArgumentError] If the PNN string is invalid
    def self.parse(pnn_string)
      pnn_string = String(pnn_string)

      matches = PATTERN.match(pnn_string)

      raise ArgumentError, "Invalid PNN string: #{pnn_string}" if matches.nil?

      {
        letter: matches[:letter],
        prefix: matches[:prefix],
        suffix: matches[:suffix]
      }.compact
    end

    # Safely parse a PNN string without raising exceptions
    #
    # @param pnn_string [String] The PNN string to parse
    # @return [Hash, nil] Hash containing the parsed components or nil if invalid
    def self.safe_parse(pnn_string)
      parse(pnn_string)
    rescue ArgumentError
      nil
    end
  end
end
