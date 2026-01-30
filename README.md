# AlpacaAPIClient

Elixir client library for the [Alpaca Markets](https://alpaca.markets/) Data API v2.

Provides access to historical and real-time market data including bars (OHLCV), trades, quotes, and snapshots.

## Installation

Add `alpaca_api_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:alpaca_api_client, "~> 0.1.0"}
  ]
end
```

## Configuration

Set your Alpaca API credentials in your application config:

```elixir
# config/config.exs
config :alpaca_api_client, AlpacaAPIClient.HTTP,
  api_key: System.get_env("APCA_API_KEY_ID"),
  api_secret: System.get_env("APCA_API_SECRET_KEY")
```

## Usage

### Historical Bars

Fetch OHLCV candlestick data with configurable timeframes.

```elixir
{:ok, bars} = AlpacaAPIClient.bars(
  symbols: ["AAPL", "MSFT"],
  timeframe: "1Day",
  start: "2024-01-01T00:00:00Z",
  end: "2024-01-31T00:00:00Z"
)

# bars => %{"AAPL" => [%AlpacaAPIClient.Types.Bar{...}, ...], "MSFT" => [...]}
```

Supported timeframes: `1Min`, `5Min`, `15Min`, `30Min`, `1Hour`, `4Hour`, `1Day`, `1Week`, `1Month`.

Additional options: `:limit`, `:adjustment` (`"raw"`, `"split"`, `"dividend"`, `"all"`), `:feed` (`"iex"`, `"sip"`, `"otc"`), `:sort` (`"asc"`, `"desc"`).

### Historical Trades

```elixir
{:ok, trades} = AlpacaAPIClient.trades(
  symbols: ["AAPL"],
  start: "2024-01-02T00:00:00Z",
  end: "2024-01-02T23:59:59Z"
)
```

### Historical Quotes

```elixir
{:ok, quotes} = AlpacaAPIClient.quotes(
  symbols: ["AAPL"],
  start: "2024-01-02T14:30:00Z",
  limit: 100
)
```

### Latest Data

```elixir
{:ok, latest_trades} = AlpacaAPIClient.latest_trades(symbols: ["AAPL", "MSFT"])
{:ok, latest_quotes} = AlpacaAPIClient.latest_quotes(symbols: ["AAPL"])
{:ok, latest_bars} = AlpacaAPIClient.latest_bars(symbols: ["AAPL"])
```

### Snapshots

Get a complete snapshot including latest trade, latest quote, minute bar, daily bar, and previous daily bar.

```elixir
{:ok, snapshots} = AlpacaAPIClient.snapshots(symbols: ["AAPL", "MSFT"])

snapshot = snapshots["AAPL"]
snapshot.latest_trade.price  # => 187.15
snapshot.daily_bar.volume    # => 82488700
```

## Pagination

All historical endpoints (bars, trades, quotes) handle pagination automatically, streaming all results across multiple API pages.

## Rate Limiting

The client enforces Alpaca's rate limit of 200 requests per minute using [Hammer](https://github.com/ExHammer/hammer). If the limit is exceeded, requests return `{:error, :rate_limited}`.

## Error Handling

All functions return tagged tuples:

```elixir
{:ok, data}                        # Success
{:error, :unauthorized}            # 401 - Invalid credentials
{:error, :forbidden}               # 403 - Forbidden
{:error, :not_found}               # 404 - Not found
{:error, :rate_limited}            # 429 or local rate limit
{:error, {:server_error, status, body}}  # 5xx
{:error, {:request_failed, reason}}      # Network error
```

## License

MIT
