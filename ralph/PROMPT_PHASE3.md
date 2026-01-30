Build the historical trades and quotes endpoints.

Requirements:
- Modules: AlpacaAPIClient.MarketData.Trades, AlpacaAPIClient.MarketData.Quotes
- Endpoints: GET /v2/stocks/trades, GET /v2/stocks/quotes
- Type structs: AlpacaAPIClient.Types.Trade, AlpacaAPIClient.Types.Quote
- Trade fields: timestamp, exchange, price, size, conditions, tape, trade_id
- Quote fields: timestamp, ask_exchange, ask_price, ask_size, bid_exchange, bid_price, bid_size, conditions, tape
- Handle pagination automatically
- Support all query params from API spec
- Write tests with fixture data

When complete:
- All tests pass (mix test --only phase3)
- Can stream all trades/quotes with pagination
- Output: <promise>PHASE3_COMPLETE</promise>
