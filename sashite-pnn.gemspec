# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-pnn"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "Modern Ruby implementation of Piece Name Notation (PNN) for abstract strategy games."
  spec.description            = "A clean, immutable Ruby interface for working with piece identifiers in PNN format. " \
                                "PNN extends PIN notation to provide style-aware piece representation with derivation " \
                                "markers for cross-style games. Features include all four fundamental piece attributes " \
                                "(type, side, state, style), enabling hybrid game scenarios and piece origin tracking. " \
                                "Perfect for game engines, analysis tools, and cross-tradition board game applications."
  spec.homepage               = "https://github.com/sashite/pnn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "sashite-pin", "~> 1.0.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pnn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pnn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pnn.rb",
    "source_code_uri"       => "https://github.com/sashite/pnn.rb",
    "specification_uri"     => "https://sashite.dev/specs/pnn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
