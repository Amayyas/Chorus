# frozen_string_literal: true

require_relative "lib/chorus/version"

Gem::Specification.new do |spec|
  spec.name = "chorus-llm"
  spec.version = Chorus::VERSION
  spec.authors = ["Amayyas"]
  spec.email = ["amayyasadn@gmail.com"]

  spec.summary = "Ruby framework for multi-agent LLM orchestration with contextual routing."
  spec.description = <<~DESC
    Chorus routes each incoming task to the right specialized LLM agent and hands it
    only the relevant slice of shared context, instead of replaying the full
    conversation history to every agent.
  DESC
  spec.homepage = "https://github.com/Amayyas/Chorus"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE.txt", "chorus-llm.gemspec"]
  spec.require_paths = ["lib"]
end
