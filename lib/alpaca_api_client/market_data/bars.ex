defmodule AlpacaAPIClient.MarketData.Bars do
  @moduledoc """
  Historical bars endpoint for the Alpaca Market Data API.

  Supports GET /v2/stocks/bars with auto-pagination.
  """

  alias AlpacaAPIClient.{Pagination, Utils}
  alias AlpacaAPIClient.Types.Bar

  @valid_timeframes ~w(1Min 5Min 15Min 30Min 1Hour 4Hour 1Day 1Week 1Month)

  @doc """
  Fetch historical bars for one or more symbols.

  ## Options

    * `:symbols` - list of stock symbols (required)
    * `:timeframe` - bar timeframe, e.g. "1Day" (required)
    * `:start` - start time (ISO 8601 string)
    * `:end` - end time (ISO 8601 string)
    * `:limit` - max bars per request (default 1000, max 10000)
    * `:adjustment` - "raw", "split", "dividend", or "all"
    * `:feed` - "iex", "sip", or "otc"
    * `:sort` - "asc" or "desc"
    * `:plug` - test plug (passed through to HTTP client)

  Returns `{:ok, %{"SYMBOL" => [%Bar{}, ...]}}` or `{:error, reason}`.
  """
  @spec get(keyword()) :: {:ok, map()} | {:error, term()}
  def get(opts) do
    symbols = Keyword.fetch!(opts, :symbols)
    timeframe = Keyword.fetch!(opts, :timeframe)

    unless timeframe in @valid_timeframes do
      raise ArgumentError,
            "invalid timeframe: #{timeframe}. Must be one of: #{Enum.join(@valid_timeframes, ", ")}"
    end

    params =
      %{symbols: Enum.join(symbols, ","), timeframe: timeframe}
      |> Utils.build_common_params(opts)
      |> Utils.maybe_put(:adjustment, opts[:adjustment])

    http_opts = [params: params] ++ Keyword.take(opts, [:plug])

    Pagination.fetch_all("/stocks/bars", http_opts, "bars", &Bar.from_map/1)
  end
end
