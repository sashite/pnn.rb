# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-pnn"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "PNN (Piece Name Notation) implementation for Ruby extending PIN with style derivation markers"

  spec.description = <<~DESC
    PNN (Piece Name Notation) extends PIN to provide style-aware piece representation
    in abstract strategy board games. This gem implements the PNN Specification v1.0.0 with
    a modern Ruby interface featuring immutable piece objects and functional programming
    principles. PNN adds derivation markers to PIN that distinguish pieces by their style
    origin, enabling cross-style game scenarios and piece origin tracking. Represents all
    four Game Protocol piece attributes with full PIN backward compatibility. Perfect for
    game engines, cross-tradition tournaments, and hybrid board game environments.
  DESC

  spec.homepage               = "https://github.com/sashite/pnn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "sashite-pin", "~> 2.0.2"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pnn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pnn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pnn.rb",
    "source_code_uri"       => "https://github.com/sashite/pnn.rb",
    "specification_uri"     => "https://sashite.dev/specs/pnn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
