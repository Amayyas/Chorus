# Chorus

[![CI](https://github.com/Amayyas/Chorus/actions/workflows/ci.yml/badge.svg)](https://github.com/Amayyas/Chorus/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/chorus-llm.svg)](https://rubygems.org/gems/chorus-llm)

Chorus is a Ruby framework for orchestrating multiple specialized LLM agents.

## The problem

Most multi-agent frameworks replay the entire conversation history to every
agent on every call. It works, but it wastes tokens (money and latency) and
pollutes each agent's context with exchanges that aren't relevant to it.

Chorus takes a different approach: a **router** dynamically decides which
agent should handle a message, and a **shared context** hands that agent only
a **relevant slice** of the history:

- the current message (the task at hand),
- its own past exchanges (role-based continuity of memory),
- a short summary of what other agents have been doing (visibility without pollution).

## Installation

Add this line to your Gemfile:

```ruby
gem "chorus-llm"
```

Then `bundle install`. The library loads via `require "chorus"`:

```ruby
require "chorus"
```

To work on this repo:

```bash
bundle install
```

Chorus needs an Anthropic API key to make real calls (the test suite never
makes network calls):

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Minimal usage example

```ruby
require "chorus"

orchestrator = Chorus::Orchestrator.new

result = orchestrator.handle("There's a bug in my sort function")
# => { agent: :coder, response: "..." }

result = orchestrator.handle("What is the capital of France?")
# => { agent: :research, response: "..." }
```

Under the hood, on every call:

1. `Chorus::Router#route` picks the agent (`:coder` or `:research`) based on
   keywords in the message.
2. `Chorus::Context#slice_for` builds the relevant context slice for that
   agent.
3. The agent (`Chorus::Agents::CoderAgent` or `Chorus::Agents::ResearchAgent`)
   sends that slice to the Anthropic API via `Chorus::Client`.
4. The response is recorded in `Chorus::Context`, tagged with the name of the
   agent that produced it.

## Running the tests

```bash
bundle exec rspec       # tests only
bundle exec rubocop     # lint only
bundle exec rake        # both (Rakefile default task)
```

No test makes a network call — `Chorus::Client` is always mocked.

## Running the demo

`examples/demo.rb` simulates a 5-message conversation alternating between
coding and research tasks, and makes REAL API calls (unlike the test suite).
Requires `ANTHROPIC_API_KEY`:

```bash
ANTHROPIC_API_KEY="sk-ant-..." ruby examples/demo.rb
```

For each message, the script prints the message received, the agent chosen
by the router, the size of the context slice sent, and the response.

## Architecture

```
lib/chorus/
├── client.rb              # sole point of contact with the Anthropic API (net/http)
├── agent.rb                # base class: factors out the call to Client
├── agents/
│   ├── coder_agent.rb      # :coder — code, debugging, explaining code
│   └── research_agent.rb   # :research — research, synthesis, factual Q&A
├── context.rb              # full history + slice_for (the core of the concept)
├── router.rb               # route(message) -> :coder | :research
└── orchestrator.rb         # entry point: handle(user_message)
```

## CI/CD

### Continuous integration (`.github/workflows/ci.yml`)

On every push and pull request:

- **Tests** — `bundle exec rspec` across a Ruby 3.2 / 3.3 / 3.4 matrix.
- **RuboCop** — lint (`.rubocop.yml`, with `rubocop-rspec` and `rubocop-performance`).
- **bundler-audit** — scans dependencies against the RubyGems advisory database.
- **Gem build** — `gem build chorus-llm.gemspec` must succeed (catches
  gemspec errors before they break a release).

### Automated releases (`.github/workflows/release.yml`)

Versioning follows [Conventional Commits](https://www.conventionalcommits.org/)
via [release-please](https://github.com/googleapis/release-please):

1. Every commit on `main` prefixed with `feat:`, `fix:`, `feat!:`, etc. updates
   (or creates) a Release PR that bumps `lib/chorus/version.rb` and generates
   `CHANGELOG.md`.
2. Merging that PR automatically:
   - creates the Git tag (`vX.Y.Z`) and a GitHub Release,
   - publishes to [RubyGems.org](https://rubygems.org/gems/chorus-llm) via
     [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/)
     (OIDC — no RubyGems API key stored as a GitHub secret).

**One-time manual configuration** (not automatable from code):

- On RubyGems.org, a trusted publisher links the `chorus-llm` gem to the
  `Amayyas/Chorus` repo, the `release.yml` workflow, and the `release`
  environment.
- In the repo's GitHub settings, a `release` environment exists
  (Settings → Environments) — used by the publish job.
- In Settings → Actions → General, *"Allow GitHub Actions to create and
  approve pull requests"* is enabled so release-please can open its Release
  PRs.

### Expected commit format

release-please needs [Conventional Commits](https://www.conventionalcommits.org/) to know what to bump:

| Prefix | Effect |
|---|---|
| `fix: ...` | patch (0.1.0 → 0.1.1) |
| `feat: ...` | minor (0.1.0 → 0.2.0) |
| `feat!: ...` or `BREAKING CHANGE:` in the body | major (0.1.0 → 1.0.0) |
| `chore:`, `docs:`, `test:`, `refactor:` | no bump, but listed in the CHANGELOG depending on config |

## Roadmap — what's NOT in the MVP (v0.1.0)

This version proves the concept with a minimal but complete foundation. It
intentionally does not include:

- **LLM-based router** — routing is currently keyword matching, not a call to
  a classification model.
- **Persistent long-term memory** — all state lives in the Ruby process's
  memory; nothing is saved to disk or a database.
- **More than 2 agents** — only `CoderAgent` and `ResearchAgent` exist.
- **Explicit agent handoff** — an agent cannot delegate to another mid-response;
  each message is handled by a single agent from start to finish.
- **LLM-generated summaries** — the other-agents summary in `slice_for` is a
  simple concatenation of truncated subjects, not an API call.
- **Advanced error handling** (retries, backoff, etc.) on API calls.
