# frozen_string_literal: true

require_relative "../agent"

module Chorus
  module Agents
    # Handles code-related tasks: writing, debugging, and explaining code.
    class CoderAgent < Chorus::Agent
      SYSTEM_PROMPT = <<~PROMPT
        You are Chorus's coding agent. You write, debug, and explain code.
        Be precise and give runnable examples when relevant. If a task is not
        related to code, say so briefly instead of improvising an answer.
      PROMPT

      def initialize(client:)
        super
        @name = :coder
        @system_prompt = SYSTEM_PROMPT
      end
    end
  end
end
