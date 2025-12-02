# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-pnn"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "PNN (Piece Name Notation) implementation for Ruby with immutable piece name objects"

  spec.description = <<~DESC
    PNN (Piece Name Notation) provides a rule-agnostic, scalable naming system for identifying
    abstract strategy board game pieces. This gem implements the PNN Specification v1.0.0 with
    a modern Ruby interface featuring immutable piece name objects and functional programming
    principles. PNN uses canonical ASCII names with optional state modifiers and optional terminal
    markers (e.g., "KING", "queen", "+ROOK", "-pawn", "KING^", "+GENERAL^") to unambiguously
    refer to game pieces across variants and traditions. Ideal for engines, protocols, and tools
    that need clear and extensible piece identifiers.
  DESC

  spec.homepage               = "https://github.com/sashite/pnn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pnn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pnn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pnn.rb",
    "source_code_uri"       => "https://github.com/sashite/pnn.rb",
    "specification_uri"     => "https://sashite.dev/specs/pnn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
