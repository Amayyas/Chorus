# frozen_string_literal: true

require "simplecov"
require "simplecov-cobertura"

# HTML for local browsing (coverage/index.html), Cobertura XML
# (coverage/coverage.xml) because Codecov's uploader doesn't understand
# SimpleCov's native .resultset.json format.
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::CoberturaFormatter
]

SimpleCov.start do
  add_filter "/spec/"
  # Set to the actual measured baseline (client.rb's HTTP-calling code is
  # mocked out everywhere and only ~44% covered — see issue #9). This is a
  # regression floor, not an aspirational target; raise it once #9 adds
  # HTTP-contract specs for Client.
  minimum_coverage 80
end

require "chorus"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
