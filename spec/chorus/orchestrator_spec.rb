# frozen_string_literal: true

RSpec.describe Chorus::Orchestrator do
  let(:client) { instance_double(Chorus::Client) }

  subject(:orchestrator) { described_class.new(client: client) }

  before do
    allow(client).to receive(:chat).and_return("mocked response")
  end

  it "never touches the network — the client is a test double throughout" do
    orchestrator.handle("There's a bug in my code")
    orchestrator.handle("What is the capital of France?")

    expect(client).to have_received(:chat).twice
  end

  it "routes a coding task to the coder agent and returns its response" do
    result = orchestrator.handle("There's a bug in my code")

    expect(result).to eq(agent: :coder, response: "mocked response")
  end

  it "routes a research task to the research agent and returns its response" do
    result = orchestrator.handle("What is the capital of France?")

    expect(result).to eq(agent: :research, response: "mocked response")
  end

  it "records both the user message and the agent's response in the context" do
    orchestrator.handle("There's a bug in my code")

    history = orchestrator.context.full_history
    expect(history.size).to eq(2)
    expect(history[0]).to have_attributes(role: :user, content: "There's a bug in my code", agent: nil)
    expect(history[1]).to have_attributes(role: :assistant, content: "mocked response", agent: :coder)
  end

  it "passes the built context slice (not the raw full history) to the agent" do
    orchestrator.handle("What is the capital of France?")

    expect(client).to have_received(:chat).with(
      system_prompt: instance_of(String),
      messages: [{ role: "user", content: "What is the capital of France?" }]
    )
  end

  it "raises for a message routed to an agent that isn't registered" do
    router = instance_double(Chorus::Router)
    allow(router).to receive(:route).and_return(:unknown_agent)
    orchestrator = described_class.new(client: client, router: router)

    expect { orchestrator.handle("anything") }.to raise_error(ArgumentError, /unknown_agent/i)
  end
end
