# frozen_string_literal: true

require_relative "context"
require_relative "router"
require_relative "agents/coder_agent"
require_relative "agents/research_agent"

module Chorus
  # Main entry point of Chorus. Ties together the Router, Context and Agents:
  # for every incoming user message it picks an agent, builds that agent's
  # context slice, calls it, and records the response.
  class Orchestrator
    # @return [Chorus::Context] the shared conversation state
    attr_reader :context

    # @param client [Chorus::Client] API client shared by all agents
    # @param router [Chorus::Router] decides which agent handles a message
    # @param context [Chorus::Context] shared conversation state
    # @param agents [Hash{Symbol => Chorus::Agent}] agent name => agent instance
    def initialize(client: Chorus::Client.new, router: Chorus::Router.new, context: Chorus::Context.new, agents: nil)
      @client = client
      @router = router
      @context = context
      @agents = agents || default_agents
    end

    # @param user_message [String] the incoming message to handle
    # @return [Hash] `{agent: Symbol, response: String}`
    def handle(user_message)
      agent_name = @router.route(user_message)
      agent = @agents.fetch(agent_name) { raise ArgumentError, "Unknown agent: #{agent_name}" }

      @context.add_message(role: :user, content: user_message)

      context_slice = @context.slice_for(agent_name, user_message)
      response = agent.call(context_slice)

      @context.add_message(role: :assistant, content: response, agent: agent_name)

      { agent: agent_name, response: response }
    end

    private

    def default_agents
      {
        coder: Chorus::Agents::CoderAgent.new(client: @client),
        research: Chorus::Agents::ResearchAgent.new(client: @client)
      }
    end
  end
end
