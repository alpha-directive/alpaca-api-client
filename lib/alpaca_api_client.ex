defmodule AlpacaAPIClient do
  @moduledoc """
  Elixir client library for the Alpaca Markets API.

  Provides access to historical market data including bars, trades, quotes,
  and snapshots via the Alpaca Data API v2.

  ## Configuration

      config :alpaca_api_client, AlpacaAPIClient.Request,
        api_key: "your-api-key-id",
        api_secret: "your-api-secret-key"

  ## Quick Start

      # Fetch daily bars
      AlpacaAPIClient.bars(symbols: ["AAPL"], timeframe: "1Day", start: "2024-01-01T00:00:00Z")

      # Fetch trades
      AlpacaAPIClient.trades(symbols: ["AAPL"], start: "2024-01-02T00:00:00Z")

      # Fetch quotes
      AlpacaAPIClient.quotes(symbols: ["AAPL"], start: "2024-01-02T00:00:00Z")

      # Fetch latest data
      AlpacaAPIClient.latest_trades(symbols: ["AAPL", "MSFT"])
      AlpacaAPIClient.latest_quotes(symbols: ["AAPL"])
      AlpacaAPIClient.latest_bars(symbols: ["AAPL"])

      # Fetch snapshots
      AlpacaAPIClient.snapshots(symbols: ["AAPL", "MSFT"])
  """

  @doc """
  Fetch historical bars for one or more symbols.

  See `AlpacaAPIClient.MarketData.Bars.get/1` for full option details.
  """
  @spec bars(keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate bars(opts), to: AlpacaAPIClient.MarketData.Bars, as: :get

  @doc """
  Fetch historical trades for one or more symbols.

  See `AlpacaAPIClient.MarketData.Trades.get/1` for full option details.
  """
  @spec trades(keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate trades(opts), to: AlpacaAPIClient.MarketData.Trades, as: :get

  @doc """
  Fetch historical quotes for one or more symbols.

  See `AlpacaAPIClient.MarketData.Quotes.get/1` for full option details.
  """
  @spec quotes(keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate quotes(opts), to: AlpacaAPIClient.MarketData.Quotes, as: :get

  @doc """
  Fetch latest trades for one or more symbols.

  See `AlpacaAPIClient.MarketData.Snapshots.latest_trades/1` for full option details.
  """
  @spec latest_trades(keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate latest_trades(opts), to: AlpacaAPIClient.MarketData.Snapshots

  @doc """
  Fetch latest quotes for one or more symbols.

  See `AlpacaAPIClient.MarketData.Snapshots.latest_quotes/1` for full option details.
  """
  @spec latest_quotes(keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate latest_quotes(opts), to: AlpacaAPIClient.MarketData.Snapshots

  @doc """
  Fetch latest bars for one or more symbols.

  See `AlpacaAPIClient.MarketData.Snapshots.latest_bars/1` for full option details.
  """
  @spec latest_bars(keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate latest_bars(opts), to: AlpacaAPIClient.MarketData.Snapshots

  @doc """
  Fetch snapshots for one or more symbols.

  See `AlpacaAPIClient.MarketData.Snapshots.get/1` for full option details.
  """
  @spec snapshots(keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate snapshots(opts), to: AlpacaAPIClient.MarketData.Snapshots, as: :get
end
