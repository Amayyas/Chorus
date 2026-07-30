# frozen_string_literal: true

module Chorus
  # Decides which agent should handle a given user message.
  #
  # v0.1.0 uses simple keyword matching (no LLM call). The public interface
  # is a single method, `route`, so this class can be swapped for an
  # LLM-based router later without touching `Orchestrator`.
  class Router
    # Words that, when present in a message, indicate a coding task.
    CODER_KEYWORDS = %w[code bug function error debug script class method variable
                        exception refactor].freeze

    DEFAULT_AGENT = :research

    # @param message [String] the raw user message
    # @return [Symbol] the agent name that should handle this message (:coder or :research)
    def route(message)
      coding_task?(message) ? :coder : DEFAULT_AGENT
    end

    private

    # Whole-word matching, not substring: a naive `include?` check would
    # match "class" inside "classical" or "error" inside "errors", routing
    # unrelated messages to :coder. Splitting into words first avoids that
    # class of false positive.
    #
    # This doesn't make keyword matching perfect — a word like "function" is
    # genuinely ambiguous ("a function" vs. "how it functions") and will
    # still misroute some messages either way. That's an inherent limitation
    # of keyword matching, not a bug; see the LLM-based router follow-up.
    def coding_task?(message)
      words = message.downcase.scan(/\w+/)
      CODER_KEYWORDS.intersect?(words)
    end
  end
end
