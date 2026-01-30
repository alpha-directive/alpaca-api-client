Build the core HTTP client module for Alpaca Markets API in Elixir.

Requirements:
- Module: AlpacaAPIClient.HTTP
- Use Req library for HTTP requests (modern, composable)
- Support both headers auth (APCA-API-KEY-ID, APCA-API-SECRET-KEY)
- Configure via application env
- Base URL: data.alpaca.markets/v2 (stocks)
- Handle rate limiting (200 req/min basic, track with Hammer)
- Return tagged tuples {:ok, data} | {:error, reason}
- Include comprehensive error handling for API errors
- Write tests using Mox for HTTP mocking

When complete:
- All tests pass (mix test --only phase1)
- Client can authenticate successfully
- Rate limiter is functional
- Output: <promise>PHASE1_COMPLETE</promise>
