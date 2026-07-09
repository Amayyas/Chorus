# frozen_string_literal: true

RSpec.describe Chorus::Context do
  subject(:context) { described_class.new }

  describe "#full_history" do
    it "returns every message that was recorded, in order" do
      context.add_message(role: :user, content: "Hello")
      context.add_message(role: :assistant, content: "Hi!", agent: :research)

      expect(context.full_history.map(&:content)).to eq(["Hello", "Hi!"])
    end

    it "does not expose the internal array (mutating the result is safe)" do
      context.add_message(role: :user, content: "Hello")
      context.full_history << "tampering"

      expect(context.full_history.size).to eq(1)
    end
  end

  describe "#slice_for" do
    it "always includes the current task as the last message" do
      slice = context.slice_for(:coder, "Fix this bug")

      expect(slice.last).to eq(role: "user", content: "Fix this bug")
    end

    it "includes no history on the very first task" do
      slice = context.slice_for(:coder, "Fix this bug")

      expect(slice).to eq([{ role: "user", content: "Fix this bug" }])
    end

    it "includes this agent's own previous (task, response) pair for continuity" do
      context.add_message(role: :user, content: "Write a sort function")
      context.add_message(role: :assistant, content: "Here is a sort function", agent: :coder)

      slice = context.slice_for(:coder, "Now add tests for it")

      expect(slice).to eq(
        [
          { role: "user", content: "Write a sort function" },
          { role: "assistant", content: "Here is a sort function" },
          { role: "user", content: "Now add tests for it" }
        ]
      )
    end

    it "does not include another agent's previous exchanges verbatim" do
      context.add_message(role: :user, content: "What is the capital of France?")
      context.add_message(role: :assistant, content: "Paris", agent: :research)

      slice = context.slice_for(:coder, "Write a sort function")

      expect(slice).not_to include(hash_including(content: "Paris"))
      expect(slice).not_to include(hash_including(content: "What is the capital of France?"))
    end

    it "includes a short summary of other agents' activity for visibility" do
      context.add_message(role: :user, content: "What is the capital of France?")
      context.add_message(role: :assistant, content: "Paris", agent: :research)

      slice = context.slice_for(:coder, "Write a sort function")

      summary_message = slice.first
      expect(summary_message[:role]).to eq("user")
      expect(summary_message[:content]).to include("[Contexte des autres agents]")
      expect(summary_message[:content]).to include("research")
      expect(summary_message[:content]).to include("What is the capital of France?")
    end

    it "truncates long subjects in the other-agents summary" do
      long_task = "a" * 200
      context.add_message(role: :user, content: long_task)
      context.add_message(role: :assistant, content: "some answer", agent: :research)

      slice = context.slice_for(:coder, "current task")

      expect(slice.first[:content].length).to be < long_task.length
    end

    it "combines own continuity history with the other-agents summary" do
      context.add_message(role: :user, content: "What is the capital of France?")
      context.add_message(role: :assistant, content: "Paris", agent: :research)
      context.add_message(role: :user, content: "Write a sort function")
      context.add_message(role: :assistant, content: "Here is a sort function", agent: :coder)

      slice = context.slice_for(:coder, "Now add tests for it")

      expect(slice.size).to eq(4)
      expect(slice[0][:content]).to include("[Contexte des autres agents]")
      expect(slice[1]).to eq(role: "user", content: "Write a sort function")
      expect(slice[2]).to eq(role: "assistant", content: "Here is a sort function")
      expect(slice[3]).to eq(role: "user", content: "Now add tests for it")
    end
  end
end
