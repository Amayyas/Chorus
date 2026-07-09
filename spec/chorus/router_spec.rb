# frozen_string_literal: true

RSpec.describe Chorus::Router do
  subject(:router) { described_class.new }

  # message => expected agent
  CASES = {
    "There's a bug in my sorting function" => :coder,
    "Can you help me debug this Ruby script?" => :coder,
    "Write a function that reverses a string" => :coder,
    "I'm getting an exception when I run my code" => :coder,
    "What is the capital of France?" => :research,
    "Can you explain how photosynthesis works?" => :research,
    "Summarize the history of the Roman Empire" => :research,
    "What's the difference between weather and climate?" => :research
  }.freeze

  CASES.each do |message, expected_agent|
    it "routes #{message.inspect} to #{expected_agent.inspect}" do
      expect(router.route(message)).to eq(expected_agent)
    end
  end

  it "is case-insensitive when matching keywords" do
    expect(router.route("THERE IS A BUG HERE")).to eq(:coder)
  end
end
