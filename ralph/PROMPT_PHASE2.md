Build the historical bars endpoint for the Alpaca Market Data client.

Requirements:
- Module: AlpacaAPIClient.MarketData.Bars
- Endpoint: GET /v2/stocks/bars
- Support all query params: symbols, timeframe, start, end, limit, adjustment, feed, sort
- Handle pagination with page_token automatically (stream all results)
- Parse response into typed structs: AlpacaAPIClient.Types.Bar
- Bar struct fields: timestamp, open, high, low, close, volume, trade_count, vwap
- Proper RFC3339 timestamp handling with DateTime
- Support timeframes: 1Min, 5Min, 15Min, 30Min, 1Hour, 4Hour, 1Day, 1Week, 1Month
- Write comprehensive tests with fixture data

When complete:
- All tests pass (mix test --only phase2)
- Can fetch bars for multiple symbols
- Pagination works correctly
- Timestamps are proper DateTime structs
- Output: <promise>PHASE2_COMPLETE</promise>
