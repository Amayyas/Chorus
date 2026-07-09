# frozen_string_literal: true

module Chorus
  # Base class for every Chorus agent. A concrete agent only needs to define
  # its `name` and `system_prompt` — the call to the LLM is factored out here.
  class Agent
    # @return [Symbol] the agent's identifier, e.g. :coder
    attr_reader :name

    # @return [String] the system prompt describing this agent's role and limits
    attr_reader :system_prompt

    # @param client [Chorus::Client] the API client used to talk to Claude
    def initialize(client:)
      @client = client
    end

    # Sends a context slice to the LLM and returns its text response.
    #
    # @param context_slice [Array<Hash>] messages formatted as `{role:, content:}`,
    #   as produced by `Chorus::Context#slice_for`.
    # @return [String] the agent's response text
    def call(context_slice)
      @client.chat(system_prompt: system_prompt, messages: context_slice)
    end
  end
end
