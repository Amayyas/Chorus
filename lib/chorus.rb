# frozen_string_literal: true

require_relative "chorus/version"
require_relative "chorus/client"
require_relative "chorus/agent"
require_relative "chorus/agents/coder_agent"
require_relative "chorus/agents/research_agent"
require_relative "chorus/context"
require_relative "chorus/router"
require_relative "chorus/orchestrator"

# Chorus is a Ruby framework for orchestrating multiple specialized LLM
# agents. A Router decides which agent should handle an incoming message, and
# a Context builds a targeted slice of shared conversation state for that
# agent — instead of replaying the full history to every call.
module Chorus
end
