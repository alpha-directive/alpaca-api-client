defmodule AlpacaAPIClient.MarketData.Snapshots do
  @moduledoc """
  Latest data and snapshot endpoints for the Alpaca Market Data API.
  """

  alias AlpacaAPIClient.Utils
  alias AlpacaAPIClient.Types.{Bar, Quote, Snapshot, Trade}

  @doc """
  Fetch latest trades for one or more symbols.

  GET /v2/stocks/trades/latest
  """
  @spec latest_trades(keyword()) :: {:ok, map()} | {:error, term()}
  def latest_trades(opts) do
    fetch_latest("/stocks/trades/latest", opts, "trades", &Trade.from_map/1)
  end

  @doc """
  Fetch latest quotes for one or more symbols.

  GET /v2/stocks/quotes/latest
  """
  @spec latest_quotes(keyword()) :: {:ok, map()} | {:error, term()}
  def latest_quotes(opts) do
    fetch_latest("/stocks/quotes/latest", opts, "quotes", &Quote.from_map/1)
  end

  @doc """
  Fetch latest bars for one or more symbols.

  GET /v2/stocks/bars/latest
  """
  @spec latest_bars(keyword()) :: {:ok, map()} | {:error, term()}
  def latest_bars(opts) do
    fetch_latest("/stocks/bars/latest", opts, "bars", &Bar.from_map/1)
  end

  @doc """
  Fetch snapshots for one or more symbols.

  GET /v2/stocks/snapshots
  """
  @spec get(keyword()) :: {:ok, map()} | {:error, term()}
  def get(opts) do
    symbols = Keyword.fetch!(opts, :symbols)
    params = %{symbols: Enum.join(symbols, ",")}
    params = Utils.maybe_put(params, :feed, opts[:feed])
    http_opts = [params: params] ++ Keyword.take(opts, [:plug])

    case AlpacaAPIClient.Request.get("/stocks/snapshots", http_opts) do
      {:ok, body} ->
        snapshots =
          body
          |> Enum.into(%{}, fn {symbol, data} -> {symbol, Snapshot.from_map(data)} end)

        {:ok, snapshots}

      {:error, _} = error ->
        error
    end
  end

  defp fetch_latest(path, opts, data_key, parser) do
    symbols = Keyword.fetch!(opts, :symbols)
    params = %{symbols: Enum.join(symbols, ",")}
    params = Utils.maybe_put(params, :feed, opts[:feed])
    http_opts = [params: params] ++ Keyword.take(opts, [:plug])

    case AlpacaAPIClient.Request.get(path, http_opts) do
      {:ok, body} ->
        result =
          (body[data_key] || %{})
          |> Enum.into(%{}, fn {symbol, data} -> {symbol, parser.(data)} end)

        {:ok, result}

      {:error, _} = error ->
        error
    end
  end
end
