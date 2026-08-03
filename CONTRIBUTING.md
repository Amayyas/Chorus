# Contributing to Chorus

Thanks for considering a contribution. This document covers everything you
need to get set up and send a good pull request.

## Development setup

```bash
git clone https://github.com/Amayyas/Chorus.git
cd Chorus
bundle install
```

Real API calls (only made by `examples/demo.rb`, never by the test suite)
need a key:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## Running checks locally

```bash
bundle exec rspec       # tests
bundle exec rubocop     # lint
bundle exec rake        # both (Rakefile default task)
```

All three run in CI on every pull request — a green PR locally should stay
green there.

### Mutation testing (optional, informational)

```bash
bundle exec mutant run --usage opensource
```

Runs [mutant](https://github.com/mbj/mutant) against the classes with real
conditional logic (`Chorus::Router`, `Chorus::Context`, `Chorus::Orchestrator`
— see `.mutant.yml`) to check whether the specs would actually catch a
regression, not just that they pass. Free for public open source use, but
requires registering this repo once under mutant's Free Project License —
see the project's own account setup at
[github.com/mbj/mutant](https://github.com/mbj/mutant). Not required to
contribute; the CI job is informational and non-blocking.

## Commit messages: Conventional Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/),
because [release-please](https://github.com/googleapis/release-please) parses
commit prefixes to decide the next version and generate the changelog.

| Prefix | Use for | Version bump |
|---|---|---|
| `feat:` | A new feature | minor |
| `fix:` | A bug fix | patch |
| `feat!:` or `BREAKING CHANGE:` in the body | A breaking change | major |
| `chore:` | Tooling, dependencies, infra with no runtime effect | none |
| `docs:` | Documentation only | none |
| `test:` | Tests only | none |
| `ci:` | CI/CD configuration | none |
| `refactor:` | Code change with no behavior change | none |

Keep the type honest — a `fix:` on something that isn't a user-facing bug
fix (e.g. a CI tweak) will trigger a release nobody asked for.

## Pull request process

1. Fork or branch, make your change.
2. Make sure `bundle exec rake` passes locally.
3. Open a PR against `main`. The template will prompt you for a summary and
   test plan.
4. CI runs the full matrix (tests across Ruby 3.2/3.3/3.4, RuboCop,
   bundler-audit, gem build). All checks must pass before merge.
5. If your change affects the public API, update the README's usage
   examples too — README code should always be copy-pasteable and correct.

## Code style

- RuboCop config (`.rubocop.yml`) is the source of truth; if a rule feels
  wrong for a specific line, prefer a targeted `# rubocop:disable` with a
  comment explaining *why*, over broadly loosening the config.
- YARD-style comments (`@param`, `@return`) on public classes and methods.
- No secrets, API keys, or credentials committed — ever, including in
  examples or specs. Use `ENV` and mocks.

## Reporting bugs / requesting features

Use the issue templates — they ask for exactly what's needed to act on a
report without a round trip. For security vulnerabilities, see
[SECURITY.md](SECURITY.md) instead of a public issue.
