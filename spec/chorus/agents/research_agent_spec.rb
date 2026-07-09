# frozen_string_literal: true

RSpec.describe Chorus::Agents::ResearchAgent do
  let(:client) { instance_double(Chorus::Client) }

  subject(:agent) { described_class.new(client: client) }

  it "is named :research" do
    expect(agent.name).to eq(:research)
  end

  it "has a system prompt describing its research role" do
    expect(agent.system_prompt).to include("research")
  end

  describe "#call" do
    it "delegates to the client with its own system prompt and the given context slice" do
      context_slice = [{ role: "user", content: "What is the capital of France?" }]
      allow(client).to receive(:chat)
        .with(system_prompt: agent.system_prompt, messages: context_slice)
        .and_return("Paris")

      expect(agent.call(context_slice)).to eq("Paris")
    end
  end
end
