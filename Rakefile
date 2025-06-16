# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "yard"

Rake::TestTask.new do |t|
  t.pattern = "test.rb"
  t.verbose = true
  t.warning = true
end

YARD::Rake::YardocTask.new

task default: %i[
  test
  yard
]
