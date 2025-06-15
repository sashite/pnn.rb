# frozen_string_literal: true

module Pnn
  # Represents a piece in PNN (Piece Name Notation) format.
  #
  # A piece consists of a single ASCII letter with optional state modifiers:
  # - Enhanced state: prefix '+'
  # - Diminished state: prefix '-'
  # - Intermediate state: suffix "'"
  #
  # The case of the letter determines ownership:
  # - Uppercase (A-Z): first player
  # - Lowercase (a-z): second player
  #
  # All instances are immutable - state manipulation methods return new instances.
  class Piece
    # PNN validation pattern matching the specification
    PNN_PATTERN = /\A(?<prefix>[-+])?(?<letter>[a-zA-Z])(?<suffix>['])?\z/

    # Valid state modifiers
    ENHANCED_PREFIX = "+"
    DIMINISHED_PREFIX = "-"
    INTERMEDIATE_SUFFIX = "'"

    # Error messages
    ERROR_INVALID_PNN = "Invalid PNN string: %s"
    ERROR_INVALID_LETTER = "Letter must be a single ASCII letter (a-z or A-Z): %s"

    # @return [String] the base letter identifier
    attr_reader :letter

    # Create a new piece instance
    #
    # @param letter [String] single ASCII letter (a-z or A-Z)
    # @param enhanced [Boolean] whether the piece has enhanced state
    # @param diminished [Boolean] whether the piece has diminished state
    # @param intermediate [Boolean] whether the piece has intermediate state
    # @raise [ArgumentError] if parameters are invalid
    def initialize(letter, enhanced: false, diminished: false, intermediate: false)
      self.class.validate_letter(letter)
      self.class.validate_state_combination(enhanced, diminished)

      @letter = letter.freeze
      @enhanced = enhanced
      @diminished = diminished
      @intermediate = intermediate

      freeze
    end

    # Parse a PNN string into a Piece object
    #
    # @param pnn_string [String] PNN notation string
    # @return [Piece] new piece instance
    # @raise [ArgumentError] if the PNN string is invalid
    # @example
    #   Pnn::Piece.parse("k")     # => #<Pnn::Piece letter="k">
    #   Pnn::Piece.parse("+k'")   # => #<Pnn::Piece letter="k" enhanced=true intermediate=true>
    def self.parse(pnn_string)
      string_value = String(pnn_string)
      matches = match_pattern(string_value)

      letter = matches[:letter]
      enhanced = matches[:prefix] == ENHANCED_PREFIX
      diminished = matches[:prefix] == DIMINISHED_PREFIX
      intermediate = matches[:suffix] == INTERMEDIATE_SUFFIX

      new(
        letter,
        enhanced:     enhanced,
        diminished:   diminished,
        intermediate: intermediate
      )
    end

    # Convert the piece to its PNN string representation
    #
    # @return [String] PNN notation string
    # @example
    #   piece.to_s  # => "+k'"
    def to_s
      prefix = if @enhanced
                 ENHANCED_PREFIX
               else
                 (@diminished ? DIMINISHED_PREFIX : "")
               end
      suffix = @intermediate ? INTERMEDIATE_SUFFIX : ""
      "#{prefix}#{letter}#{suffix}"
    end

    # Create a new piece with enhanced state
    #
    # @return [Piece] new piece instance with enhanced state
    # @example
    #   piece.enhance  # k => +k
    def enhance
      return self if enhanced?

      self.class.new(
        letter,
        enhanced:     true,
        diminished:   false,
        intermediate: @intermediate
      )
    end

    # Create a new piece without enhanced state
    #
    # @return [Piece] new piece instance without enhanced state
    # @example
    #   piece.unenhance  # +k => k
    def unenhance
      return self unless enhanced?

      self.class.new(
        letter,
        enhanced:     false,
        diminished:   @diminished,
        intermediate: @intermediate
      )
    end

    # Create a new piece with diminished state
    #
    # @return [Piece] new piece instance with diminished state
    # @example
    #   piece.diminish  # k => -k
    def diminish
      return self if diminished?

      self.class.new(
        letter,
        enhanced:     false,
        diminished:   true,
        intermediate: @intermediate
      )
    end

    # Create a new piece without diminished state
    #
    # @return [Piece] new piece instance without diminished state
    # @example
    #   piece.undiminish  # -k => k
    def undiminish
      return self unless diminished?

      self.class.new(
        letter,
        enhanced:     @enhanced,
        diminished:   false,
        intermediate: @intermediate
      )
    end

    # Create a new piece with intermediate state
    #
    # @return [Piece] new piece instance with intermediate state
    # @example
    #   piece.intermediate  # k => k'
    def intermediate
      return self if intermediate?

      self.class.new(
        letter,
        enhanced:     @enhanced,
        diminished:   @diminished,
        intermediate: true
      )
    end

    # Create a new piece without intermediate state
    #
    # @return [Piece] new piece instance without intermediate state
    # @example
    #   piece.unintermediate  # k' => k
    def unintermediate
      return self unless intermediate?

      self.class.new(
        letter,
        enhanced:     @enhanced,
        diminished:   @diminished,
        intermediate: false
      )
    end

    # Create a new piece without any modifiers
    #
    # @return [Piece] new piece instance with only the base letter
    # @example
    #   piece.bare  # +k' => k
    def bare
      return self if bare?

      self.class.new(letter)
    end

    # Create a new piece with opposite ownership (case)
    #
    # @return [Piece] new piece instance with flipped case
    # @example
    #   piece.flip  # K => k, k => K
    def flip
      flipped_letter = letter.swapcase

      self.class.new(
        flipped_letter,
        enhanced:     @enhanced,
        diminished:   @diminished,
        intermediate: @intermediate
      )
    end

    # Check if the piece has enhanced state
    #
    # @return [Boolean] true if enhanced
    def enhanced?
      @enhanced
    end

    # Check if the piece has diminished state
    #
    # @return [Boolean] true if diminished
    def diminished?
      @diminished
    end

    # Check if the piece has intermediate state
    #
    # @return [Boolean] true if intermediate
    def intermediate?
      @intermediate
    end

    # Check if the piece has no modifiers
    #
    # @return [Boolean] true if no modifiers are present
    def bare?
      !enhanced? && !diminished? && !intermediate?
    end

    # Check if the piece belongs to the first player (uppercase)
    #
    # @return [Boolean] true if uppercase letter
    def uppercase?
      letter == letter.upcase
    end

    # Check if the piece belongs to the second player (lowercase)
    #
    # @return [Boolean] true if lowercase letter
    def lowercase?
      letter == letter.downcase
    end

    # Custom equality comparison
    #
    # @param other [Object] object to compare with
    # @return [Boolean] true if pieces are equal
    def ==(other)
      return false unless other.is_a?(self.class)

      letter == other.letter &&
        enhanced? == other.enhanced? &&
        diminished? == other.diminished? &&
        intermediate? == other.intermediate?
    end

    # Custom hash implementation for use in collections
    #
    # @return [Integer] hash value
    def hash
      [letter, @enhanced, @diminished, @intermediate].hash
    end

    # Custom inspection for debugging
    #
    # @return [String] detailed string representation
    def inspect
      modifiers = []
      modifiers << "enhanced=true" if enhanced?
      modifiers << "diminished=true" if diminished?
      modifiers << "intermediate=true" if intermediate?

      modifier_str = modifiers.empty? ? "" : " #{modifiers.join(' ')}"
      "#<#{self.class.name}:0x#{object_id.to_s(16)} letter='#{letter}'#{modifier_str}>"
    end

    # Validate that the letter is a single ASCII letter
    #
    # @param letter [String] the letter to validate
    # @raise [ArgumentError] if invalid
    def self.validate_letter(letter)
      letter_str = String(letter)
      return if letter_str.match?(/\A[a-zA-Z]\z/)

      raise ::ArgumentError, format(ERROR_INVALID_LETTER, letter_str)
    end

    # Validate that enhanced and diminished states are not both true
    #
    # @param enhanced [Boolean] enhanced state
    # @param diminished [Boolean] diminished state
    # @raise [ArgumentError] if both are true
    def self.validate_state_combination(enhanced, diminished)
      return unless enhanced && diminished

      raise ::ArgumentError, "A piece cannot be both enhanced and diminished"
    end

    # Match PNN pattern against string
    #
    # @param string [String] string to match
    # @return [MatchData] match data
    # @raise [ArgumentError] if string doesn't match
    def self.match_pattern(string)
      matches = PNN_PATTERN.match(string)
      return matches if matches

      raise ::ArgumentError, format(ERROR_INVALID_PNN, string)
    end

    private_class_method :match_pattern
  end
end
