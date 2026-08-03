# Security Policy

## Supported Versions

Chorus is pre-1.0 and moves fast. Security fixes are only guaranteed for the
latest published version on [RubyGems.org](https://rubygems.org/gems/chorus-llm).

| Version | Supported |
| ------- | --------- |
| Latest  | ✅ |
| Older   | ❌ |

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Use one of these private channels instead:

1. **Preferred:** [GitHub private vulnerability reporting](https://github.com/Amayyas/Chorus/security/advisories/new)
   (Security tab → "Report a vulnerability").
2. **Alternative:** email amayyas.aouadene@epitech.eu with details.

Please include:

- A description of the vulnerability and its potential impact
- Steps to reproduce (a minimal repro is ideal)
- The affected version(s)

You should get an acknowledgment within a few days. This is a solo-maintained
open-source project, not a company with an SLA — please be patient, but
reports won't be ignored.

## Scope

Things worth reporting:

- Anything that could leak the `ANTHROPIC_API_KEY` a consumer configures
  (e.g. logging it, sending it somewhere unexpected)
- Injection or unsafe deserialization in how `Chorus::Client` builds
  requests or parses responses
- Dependency vulnerabilities not yet caught by the project's own
  `bundler-audit` CI check

Things generally out of scope:

- Vulnerabilities in the Anthropic API itself — report those to Anthropic
- Issues that require an attacker to already control the host process
  running Chorus (e.g. arbitrary code execution via a malicious Gemfile)
