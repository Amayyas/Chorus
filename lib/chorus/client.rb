# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Chorus
  # Raised when ANTHROPIC_API_KEY is not set in the environment.
  class MissingAPIKeyError < StandardError
    def initialize(msg = "ANTHROPIC_API_KEY is not set. Export it before using Chorus.")
      super
    end
  end

  # Raised when the Anthropic API returns a non-2xx response.
  class APIError < StandardError; end

  # Thin wrapper around the Anthropic Messages API. This is the ONLY class in
  # Chorus allowed to perform HTTP calls — every agent goes through it.
  class Client
    API_URL = "https://api.anthropic.com/v1/messages"
    ANTHROPIC_VERSION = "2023-06-01"
    DEFAULT_MODEL = "claude-opus-4-8"
    DEFAULT_MAX_TOKENS = 4096

    # @param api_key [String, nil] Anthropic API key. Defaults to ENV["ANTHROPIC_API_KEY"].
    # @param model [String] model id to use for every call made by this client.
    def initialize(api_key: ENV["ANTHROPIC_API_KEY"], model: DEFAULT_MODEL)
      raise MissingAPIKeyError if api_key.nil? || api_key.empty?

      @api_key = api_key
      @model = model
    end

    # Sends a single-turn (or multi-turn) request to the Messages API.
    #
    # @param system_prompt [String] the system prompt describing the agent's role.
    # @param messages [Array<Hash>] conversation turns, each `{role:, content:}`.
    # @param max_tokens [Integer] maximum tokens to generate.
    # @return [String] the text of Claude's response.
    def chat(system_prompt:, messages:, max_tokens: DEFAULT_MAX_TOKENS)
      response = post_message(system_prompt: system_prompt, messages: messages, max_tokens: max_tokens)
      extract_text(response)
    end

    private

    def post_message(system_prompt:, messages:, max_tokens:)
      uri = URI(API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["x-api-key"] = @api_key
      request["anthropic-version"] = ANTHROPIC_VERSION
      request.body = JSON.generate(
        model: @model,
        max_tokens: max_tokens,
        system: system_prompt,
        messages: messages
      )

      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess)
        raise APIError, "Anthropic API error (#{response.code}): #{response.body}"
      end

      JSON.parse(response.body)
    end

    def extract_text(response)
      content = response.fetch("content", [])
      text_block = content.find { |block| block["type"] == "text" }
      text_block ? text_block["text"] : ""
    end
  end
end
