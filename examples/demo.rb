#!/usr/bin/env ruby
# frozen_string_literal: true

# Demonstrates the full Chorus flow end-to-end against the real Anthropic API.
#
# Unlike the RSpec suite, this script makes real network calls, so it needs a
# valid ANTHROPIC_API_KEY in the environment:
#
#   ANTHROPIC_API_KEY=sk-ant-... ruby examples/demo.rb

require_relative "../lib/chorus"

MESSAGES = [
  "There's a bug in my Ruby function: it returns nil instead of the sum of an array.",
  "What is the capital of France?",
  "Can you write a function that checks if a string is a palindrome?",
  "Can you explain briefly why the sky is blue?",
  "I'm getting an exception when I call my palindrome function on an empty string — why?"
].freeze

def separator
  puts "-" * 80
end

begin
  orchestrator = Chorus::Orchestrator.new
rescue Chorus::MissingAPIKeyError => e
  warn "Error: #{e.message}"
  exit 1
end

MESSAGES.each_with_index do |message, index|
  separator
  puts "Message ##{index + 1}: #{message}"

  agent_name = Chorus::Router.new.route(message)
  context_slice = orchestrator.context.slice_for(agent_name, message)

  puts "Agent chosen by the router: #{agent_name}"
  puts "Context slice size sent: #{context_slice.size} message(s)"

  result = orchestrator.handle(message)

  puts "Agent response:"
  puts result[:response]
end

separator
puts "Conversation finished. Full history (#{orchestrator.context.full_history.size} messages) available via orchestrator.context.full_history."
