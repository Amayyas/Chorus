# frozen_string_literal: true

RSpec.describe Chorus::Agents::CoderAgent do
  let(:client) { instance_double(Chorus::Client) }

  subject(:agent) { described_class.new(client: client) }

  it "is named :coder" do
    expect(agent.name).to eq(:coder)
  end

  it "has a system prompt describing its coding role" do
    expect(agent.system_prompt).to include("coding")
  end

  describe "#call" do
    it "delegates to the client with its own system prompt and the given context slice" do
      context_slice = [{ role: "user", content: "Fix this bug" }]
      allow(client).to receive(:chat)
        .with(system_prompt: agent.system_prompt, messages: context_slice)
        .and_return("Here is the fix")

      expect(agent.call(context_slice)).to eq("Here is the fix")
    end
  end
end
