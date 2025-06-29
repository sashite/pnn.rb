# frozen_string_literal: true

# Sashité namespace for board game notation libraries
module Sashite
  # Piece Name Notation (PNN) implementation for Ruby
  #
  # PNN extends PIN (Piece Identifier Notation) to provide style-aware piece
  # representation in abstract strategy board games. PNN adds a derivation marker
  # that distinguishes pieces by their style origin, enabling cross-style game
  # scenarios and piece origin tracking.
  #
  # Format: <pin>[<suffix>]
  # - PIN component: [<state>]<letter> (from PIN specification)
  # - Suffix: "'" for foreign style, none for native style
  #
  # @see https://sashite.dev/specs/pnn/1.0.0/ PNN Specification v1.0.0
  # @see https://sashite.dev/specs/pin/1.0.0/ PIN Specification v1.0.0
  # @author Sashité
end

require_relative "sashite/pnn"
