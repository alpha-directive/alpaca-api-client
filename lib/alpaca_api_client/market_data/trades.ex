defmodule AlpacaAPIClient.MarketData.Trades do
  @moduledoc """
  Historical trades endpoint for the Alpaca Market Data API.

  Supports GET /v2/stocks/trades with auto-pagination.
  """

  alias AlpacaAPIClient.{Pagination, Utils}
  alias AlpacaAPIClient.Types.Trade

  @doc """
  Fetch historical trades for one or more symbols.

  ## Options

    * `:symbols` - list of stock symbols (required)
    * `:start` - start time (ISO 8601 string)
    * `:end` - end time (ISO 8601 string)
    * `:limit` - max trades per request
    * `:feed` - "iex", "sip", or "otc"
    * `:sort` - "asc" or "desc"
    * `:plug` - test plug (passed through to HTTP client)

  Returns `{:ok, %{"SYMBOL" => [%Trade{}, ...]}}` or `{:error, reason}`.
  """
  @spec get(keyword()) :: {:ok, map()} | {:error, term()}
  def get(opts) do
    symbols = Keyword.fetch!(opts, :symbols)

    params =
      %{symbols: Enum.join(symbols, ",")}
      |> Utils.build_common_params(opts)

    http_opts = [params: params] ++ Keyword.take(opts, [:plug])

    Pagination.fetch_all("/stocks/trades", http_opts, "trades", &Trade.from_map/1)
  end
end
