# frozen_string_literal: true

module Chorus
  # Represents the full shared state of a conversation, and knows how to carve
  # out the slice of it that is relevant to a given agent and task.
  #
  # This class is the heart of Chorus's concept: instead of replaying the
  # entire conversation to every agent, `slice_for` builds a small, targeted
  # view of the context. See the comments inside `slice_for` for the exact
  # rules — this logic is intentionally simple in v0.1.0 (no LLM calls) and
  # is the primary thing to refine in v0.2.0.
  class Context
    Message = Struct.new(:role, :content, :agent, :timestamp, keyword_init: true)

    # How many characters of a task we keep when summarizing another agent's
    # activity for a teammate. Kept short on purpose — it's a pointer, not a
    # transcript.
    SUBJECT_LENGTH = 60

    def initialize
      @messages = []
    end

    # @param role [Symbol] :user or :assistant
    # @param content [String] the message text
    # @param agent [Symbol, nil] which agent produced this message (nil for user messages)
    # @return [void]
    def add_message(role:, content:, agent: nil)
      @messages << Message.new(role: role, content: content, agent: agent, timestamp: Time.now)
    end

    # @return [Array<Message>] the complete, unfiltered history — for debugging/logging only.
    def full_history
      @messages.dup
    end

    # Builds the context slice for `agent_name` working on `task`.
    #
    # The slice always contains, in order:
    #   1. A one-line summary of what OTHER agents have been doing, so this
    #      agent has situational awareness without the full transcript of
    #      their conversations. Built by concatenating short subjects
    #      (truncated prior task text) — no LLM call involved in v0.1.0.
    #   2. This agent's own past (task, response) pairs, so it remembers what
    #      it has already said — continuity of memory per role.
    #   3. The current task, which is always the final entry.
    #
    # The Anthropic API only requires the conversation to start with a `user`
    # turn; consecutive same-role turns are merged server-side, so we don't
    # need to strictly alternate roles here.
    #
    # @param agent_name [Symbol] the agent about to handle `task`, e.g. :coder
    # @param task [String] the current user message
    # @return [Array<Hash>] messages shaped as `{role:, content:}`, ready for `Chorus::Client#chat`
    def slice_for(agent_name, task)
      slice = []

      summary = other_agents_summary(agent_name)
      slice << { role: "user", content: "[Contexte des autres agents] #{summary}" } if summary

      slice.concat(own_history_for(agent_name))

      slice << { role: "user", content: task }
      slice
    end

    private

    # Reconstructs (task, response) pairs previously produced by `agent_name`,
    # so it can pick up where it left off instead of starting cold each time.
    def own_history_for(agent_name)
      pairs = []

      @messages.each_with_index do |message, index|
        next unless message.role == :assistant && message.agent == agent_name

        preceding = @messages[index - 1] if index.positive?
        pairs << { role: "user", content: preceding.content } if preceding && preceding.role == :user
        pairs << { role: "assistant", content: message.content }
      end

      pairs
    end

    # Short, no-LLM summary of what agents OTHER than `agent_name` have been
    # asked to do, so `agent_name` has visibility without full pollution.
    def other_agents_summary(agent_name)
      subjects = @messages.each_with_index.filter_map do |message, index|
        next unless message.role == :assistant && message.agent && message.agent != agent_name

        preceding = @messages[index - 1]
        next unless preceding && preceding.role == :user

        "#{message.agent}: #{truncate(preceding.content)}"
      end

      return nil if subjects.empty?

      subjects.uniq.join("; ")
    end

    def truncate(text)
      return text if text.length <= SUBJECT_LENGTH

      "#{text[0, SUBJECT_LENGTH]}…"
    end
  end
end
