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

    def coding_task?(message)
      normalized = message.downcase
      # rubocop:disable Style/ArrayIntersect -- `normalized` is a String, not
      # an Array; Array#intersect? would raise a TypeError here. This is a
      # substring check on each keyword, not an array-element intersection.
      CODER_KEYWORDS.any? { |keyword| normalized.include?(keyword) }
      # rubocop:enable Style/ArrayIntersect
    end
  end
end
