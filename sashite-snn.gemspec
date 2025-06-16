# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-snn"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "Style Name Notation (SNN) support for the Ruby language."

  spec.description = <<~DESC
    A clean, minimal Ruby implementation of Style Name Notation (SNN) for abstract strategy games.
    SNN provides a consistent and rule-agnostic format for identifying piece styles, enabling
    clear distinction between different piece traditions, variants, or design approaches within
    multi-style gaming environments. Features include player-based casing, style validation,
    and cross-style compatibility. Perfect for game engines, multi-tradition environments,
    and hybrid gaming systems.
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
