# frozen_string_literal: true

module Pnn
  # Parses PNN strings into their component parts
  class Parser
    # PNN regex capture groups for parsing
    PATTERN = /\A(?<prefix>[-+])?(?<letter>[a-zA-Z])(?<suffix>['])?\z/

    # Error message for invalid PNN string
    ERROR_INVALID_PNN = "Invalid PNN string: %s"

    # Component keys for the result hash
    COMPONENT_KEYS = %i[letter prefix suffix].freeze

    # Parse a PNN string into its components
    #
    # @param pnn_string [String] The PNN string to parse
    # @return [Hash] Hash containing the parsed components
    # @raise [ArgumentError] If the PNN string is invalid
    def self.parse(pnn_string)
      string_value = String(pnn_string)
      matches = match_pattern(string_value)
      extract_components(matches)
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

    # Match the PNN pattern against a string
    #
    # @param string [String] The string to match
    # @return [MatchData] The match data
    # @raise [ArgumentError] If the string doesn't match the pattern
    def self.match_pattern(string)
      matches = PATTERN.match(string)

      return matches if matches

      raise ArgumentError, format(ERROR_INVALID_PNN, string)
    end

    # Extract components from match data
    #
    # @param matches [MatchData] The match data
    # @return [Hash] Hash containing the parsed components
    def self.extract_components(matches)
      COMPONENT_KEYS.each_with_object({}) do |key, result|
        value = matches[key]
        result[key] = value if value
      end
    end

    private_class_method :match_pattern, :extract_components
  end
end
