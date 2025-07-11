# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-snn"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "SNN (Style Name Notation) implementation for Ruby with immutable style name objects"

  spec.description = <<~DESC
    SNN (Style Name Notation) provides a rule-agnostic, scalable naming system for identifying
    abstract strategy board game styles. This gem implements the SNN Specification v1.0.0 with
    a modern Ruby interface featuring immutable style name objects and functional programming
    principles. SNN uses canonical ASCII names (e.g., "Shogi", "Go9x9") to unambiguously refer
    to game styles across variants and traditions. Ideal for engines, protocols, and tools that
    need clear and extensible style identifiers.
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
    "specification_uri"     => "https://sashite.dev/specs/snn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
