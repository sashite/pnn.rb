# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-snn"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "SNN (Style Name Notation) implementation for Ruby with immutable style objects"

  spec.description = <<~DESC
    SNN (Style Name Notation) provides a rule-agnostic format for identifying styles
    in abstract strategy board games. This gem implements the SNN Specification v1.0.0 with
    a modern Ruby interface featuring immutable style objects and functional programming
    principles. SNN uses standardized naming conventions with case-based side encoding,
    enabling clear distinction between different traditions in multi-style gaming environments.
    Perfect for cross-tradition matches, game engines, and hybrid gaming systems.
  DESC

  spec.homepage               = "https://github.com/sashite/snn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/snn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/snn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/snn.rb",
    "source_code_uri"       => "https://github.com/sashite/snn.rb",
    "specification_uri"     => "https://sashite.dev/documents/snn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
