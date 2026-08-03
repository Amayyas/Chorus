# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "bundler-audit", "~> 0.9"
# Pinned below 0.16 deliberately: mutant/mutant-rspec 0.16.0 raised their
# required Ruby to >= 3.3, but this project's CI matrix and
# required_ruby_version still support 3.2. 0.15.1 is the latest release
# that supports 3.2. Revisit this pin if/when 3.2 support is dropped.
gem "mutant", "~> 0.15.1", require: false
gem "mutant-rspec", "~> 0.15.1", require: false
gem "rake", "~> 13.0"
gem "rspec", "~> 3.13"
gem "rubocop", "~> 1.75"
gem "rubocop-performance", "~> 1.24"
gem "rubocop-rspec", "~> 3.6"
