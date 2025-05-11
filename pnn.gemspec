# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "pnn"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "PNN (Piece Name Notation) support for the Ruby language."
  spec.description            = "A Ruby interface for serialization and deserialization of piece identifiers in PNN format. " \
                                "PNN is a consistent and rule-agnostic format for representing pieces in abstract strategy " \
                                "board games, providing a standardized way to identify pieces independent of any specific " \
                                "game rules or mechanics."
  spec.homepage               = "https://github.com/sashite/pnn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/pnn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/pnn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/pnn.rb",
    "source_code_uri"       => "https://github.com/sashite/pnn.rb",
    "specification_uri"     => "https://sashite.dev/documents/pnn/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
