# frozen_string_literal: true

require_relative "../agent"

module Chorus
  module Agents
    # Handles research/factual/explanatory tasks: information lookup and synthesis.
    class ResearchAgent < Chorus::Agent
      SYSTEM_PROMPT = <<~PROMPT
        You are Chorus's research agent. You answer questions that require
        factual explanation, synthesis of information, or general knowledge.
        Be concise and cite the reasoning behind your answer when useful.
      PROMPT

      def initialize(client:)
        super
        @name = :research
        @system_prompt = SYSTEM_PROMPT
      end
    end
  end
end
