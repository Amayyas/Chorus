# frozen_string_literal: true

RSpec.describe Chorus::Router do
  subject(:router) { described_class.new }

  # message => expected agent
  cases = {
    "There's a bug in my sorting function" => :coder,
    "Can you help me debug this Ruby script?" => :coder,
    "Write a function that reverses a string" => :coder,
    "I'm getting an exception when I run my code" => :coder,
    "What is the capital of France?" => :research,
    "Can you explain how photosynthesis works?" => :research,
    "Summarize the history of the Roman Empire" => :research,
    "What's the difference between weather and climate?" => :research
  }

  cases.each do |message, expected_agent|
    it "routes #{message.inspect} to #{expected_agent.inspect}" do
      expect(router.route(message)).to eq(expected_agent)
    end
  end

  it "is case-insensitive when matching keywords" do
    expect(router.route("THERE IS A BUG HERE")).to eq(:coder)
  end

  # Regression cases for a substring-matching bug: a naive `include?` check
  # against the raw message matched "class" inside "classical"/"classic" and
  # "error" inside "errors", misrouting these to :coder.
  describe "whole-word matching (regression)" do
    cases = {
      "What is the classical explanation for gravity?" => :research,
      "Can you summarize this classic novel?" => :research,
      "What errors did historians identify in this account?" => :research
    }

    cases.each do |message, expected_agent|
      it "does not misroute #{message.inspect} on a keyword substring" do
        expect(router.route(message)).to eq(expected_agent)
      end
    end

    it "documents a known residual limitation: standalone ambiguous keywords still misroute" do
      # "function" is a whole word here, not a substring match, but it's
      # inherently ambiguous ("a function" vs. "how it functions"). Keyword
      # matching can't disambiguate that — only a semantic/LLM-based router
      # can. This spec exists so the behavior is a documented, intentional
      # limitation rather than a silent surprise.
      expect(router.route("How does a democracy function in practice?")).to eq(:coder)
    end
  end
end
