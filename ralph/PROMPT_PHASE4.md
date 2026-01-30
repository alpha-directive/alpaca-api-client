Build the latest data and snapshot endpoints.

Requirements:
- Module: AlpacaAPIClient.MarketData.Snapshots
- Endpoints:
  - GET /v2/stocks/trades/latest
  - GET /v2/stocks/quotes/latest  
  - GET /v2/stocks/bars/latest
  - GET /v2/stocks/snapshots
- Snapshot struct includes: latest_trade, latest_quote, minute_bar, daily_bar, prev_daily_bar
- Support single symbol and multi-symbol variants
- Write tests

When complete:
- All tests pass (mix test --only phase4)
- All latest/snapshot endpoints functional
- Output: <promise>PHASE4_COMPLETE</promise>
