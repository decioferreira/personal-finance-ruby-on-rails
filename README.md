# Personal Finance

An open-source, privacy-focused personal finance web application, and the first
step toward a broader **Personal Financial Intelligence** platform.

## Vision

This project aims to become an open-source, privacy-focused personal financial
intelligence platform. Future capabilities may include:

- AI-powered financial analysis
- MCP integration
- AI evaluations
- forecasting
- receipt processing
- bank synchronization
- mobile applications
- local/private AI
- hosted SaaS

None of the above is implemented yet. This repository currently contains a
deliberately small, solid **MVP foundation** — a straightforward Rails
monolith — built with test-driven development as a way to practice
professional Ruby/Rails backend development with AI-assisted tooling used
responsibly (see [AGENTS.md-style notes](#ai-assisted-development) below).

## Current MVP scope

A user can:

- register, log in, and log out
- create categories (simple, flat, user-owned — no hierarchy)
- add, edit, and delete spending entries (date, amount, description, category)
- record one income amount per calendar month
- view a dashboard for a selected month showing income, spending, remaining
  balance, and a pie chart of spending by category
- navigate between months

Every piece of financial data is scoped to its owner and enforced server-side
(not just hidden in the UI) — see [Security](#security) below.

**Not implemented yet** (see [Roadmap](#roadmap)): AI features, MCP, evals,
forecasting, bank integrations, receipt processing, a mobile app, or a hosted
SaaS offering.

## Technology stack

- Ruby 3.4.10, Rails 8.1
- SQLite (via the `sqlite3` gem) — no separate database server required
- Rails views (ERB), Propshaft asset pipeline, importmap-rails (no Node/JS
  build step), Hotwire (Turbo + Stimulus)
- [Chart.js](https://www.chartjs.org/) (pinned via importmap) for the
  dashboard's category pie chart — the backend computes and serializes all
  totals; the chart only renders what it's given
- RSpec, FactoryBot, Shoulda Matchers for testing
- RuboCop (`rubocop-rails-omakase`), Brakeman, `bundler-audit` for code
  quality and security scanning
- Rails' built-in authentication generator (`has_secure_password` +
  session cookies) — no Devise or other auth gem

## Local setup

Requirements: Ruby 3.4.10 (see `.ruby-version`; managed here via
[rbenv](https://github.com/rbenv/rbenv)) and Bundler.

```bash
git clone <this repo>
cd personal-finance-ruby-on-rails
bundle install
bin/rails db:setup   # creates and migrates the dev + test SQLite databases
```

## Running the development server

```bash
bin/rails server
```

Then visit `http://localhost:3000`, register an account, and start adding
categories and spending entries.

## Running the test suite

```bash
bundle exec rspec          # full suite
bundle exec rubocop        # style/lint
bin/rails zeitwerk:check   # autoloading sanity check
bin/brakeman               # static security analysis
bin/bundler-audit          # dependency vulnerability scan
```

The project was built test-first throughout: every model and controller has
model/request specs written before the implementation, including explicit
coverage for monetary precision (amounts are `BigDecimal` via Active
Record's `decimal` type — never `Float`), month-boundary edge cases (first
day, last day, adjacent months), and cross-user data isolation.

## Project structure

Conventional Rails layout — no extra layers (`services/`, `queries/`, etc.)
have been introduced, since none has been needed yet:

```text
app/
├── controllers/    # thin; simple AR queries live here directly
├── models/         # User, Category, SpendingEntry, MonthlyIncome
├── views/
└── javascript/controllers/   # Stimulus controllers (currently: the chart)

config/
db/
spec/               # RSpec: models/, requests/, factories/
```

## Security

All financial data belongs to a `User` and every controller looks records up
through `Current.user.<association>` (e.g. `Current.user.categories.find(...)`)
rather than `Category.find(...)`. Requesting another user's record ID 404s
instead of leaking or allowing mutation of their data — this is enforced in
the backend and covered by dedicated request specs, not just hidden by the
UI. Data integrity is also enforced at the database level where it matters
(unique indexes, check constraints, foreign keys) in addition to Rails
validations.

## AI-assisted development

This project was built collaboratively with an AI coding agent (Claude Code),
used as a way to practice both professional Rails development and effective
AI-assisted development. The intent throughout was: AI proposes, human
decides — non-obvious architectural choices were surfaced and explained
rather than made silently, and every feature followed a strict
red/green/refactor TDD cycle rather than "write it all, test later."

## Current limitations

- No password reset email delivery is configured beyond Rails' default
  (uses `deliver_later`; no mailer/SMTP configured for local dev)
- No pagination on spending entries or categories lists
- Categories are flat (no hierarchy/subcategories)
- Single currency (EUR), not configurable per user
- No automated browser/system tests (no Selenium/Chrome driver assumed
  present in the dev environment); UI changes were verified via request
  specs plus manual smoke testing against a running server

## Roadmap

Next up, roughly in order of dependency:

1. Polish/harden the current MVP (pagination, better validation messages,
   accessibility pass)
2. AI-assisted financial analysis and an MCP server exposing this data
3. Forecasting
4. Receipt processing
5. Bank synchronization
6. Mobile clients
7. A hosted SaaS version

Each of these will be scoped and designed deliberately when the time comes,
rather than pre-built as speculative abstractions today.
