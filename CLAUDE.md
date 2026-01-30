# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Elixir OTP application — a client library for the Alpaca Markets API. Uses Mix build system, requires Elixir >= 1.18.

## Common Commands

- `mix deps.get` — install dependencies
- `mix compile` — compile the project
- `mix test` — run all tests
- `mix test --only phase1` — run Phase 1 tests (HTTP client)
- `mix test --only phase2` — run Phase 2 tests (Market Data)
- `mix test path/to/test_file.exs` — run a single test file
- `mix test path/to/test_file.exs:LINE` — run a specific test
- `mix format` — format code
- `mix format --check-formatted` — check formatting

## Architecture

**Module structure**:

- `AlpacaAPIClient.Request` — Core HTTP client using Req. Handles authentication (ALPACA-API-KEY-ID/ALPACA-API-SECRET-KEY headers), rate limiting (200 req/min via Hammer), and error handling with tagged tuples (`{:ok, data}` | `{:error, reason}`).
- `AlpacaAPIClient.RequestBehaviour` — Behaviour for the HTTP client, enabling test mocking.
- `AlpacaAPIClient.Utils` — Shared utilities: `maybe_put/3`, `parse_timestamp!/1`, `build_common_params/2`.
- `AlpacaAPIClient.Pagination` — Shared pagination logic (`fetch_all/4`) for paginated market data endpoints.
- `AlpacaAPIClient.MarketData.Bars` — Bars endpoint (`GET /v2/stocks/bars`). Supports auto-pagination, timeframe params, and returns typed `AlpacaAPIClient.Types.Bar` structs.
- `AlpacaAPIClient.MarketData.Trades` — Trades endpoint (`GET /v2/stocks/trades`). Auto-pagination, returns `AlpacaAPIClient.Types.Trade` structs.
- `AlpacaAPIClient.MarketData.Quotes` — Quotes endpoint (`GET /v2/stocks/quotes`). Auto-pagination, returns `AlpacaAPIClient.Types.Quote` structs.
- `AlpacaAPIClient.MarketData.Snapshots` — Latest data and snapshot endpoints.
- `AlpacaAPIClient.Application` — OTP supervisor.

Base URL: `data.alpaca.markets/v2`

## Key Dependencies (planned)

- **Req** — HTTP client
- **Hammer** — rate limiting
- **Mox** — HTTP mocking in tests

## Development Phases

Phase requirements and acceptance criteria are in `ralph/PROMPT_PHASE1.md` and `ralph/PROMPT_PHASE2.md`. Consult these before implementing.
