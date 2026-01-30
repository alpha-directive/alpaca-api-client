defmodule AlpacaAPIClient.MarketData.Quotes do
  @moduledoc """
  Historical quotes endpoint for the Alpaca Market Data API.

  Supports GET /v2/stocks/quotes with auto-pagination.
  """

  alias AlpacaAPIClient.{Pagination, Utils}
  alias AlpacaAPIClient.Types.Quote

  @doc """
  Fetch historical quotes for one or more symbols.

  ## Options

    * `:symbols` - list of stock symbols (required)
    * `:start` - start time (ISO 8601 string)
    * `:end` - end time (ISO 8601 string)
    * `:limit` - max quotes per request
    * `:feed` - "iex", "sip", or "otc"
    * `:sort` - "asc" or "desc"
    * `:plug` - test plug (passed through to HTTP client)

  Returns `{:ok, %{"SYMBOL" => [%Quote{}, ...]}}` or `{:error, reason}`.
  """
  @spec get(keyword()) :: {:ok, map()} | {:error, term()}
  def get(opts) do
    symbols = Keyword.fetch!(opts, :symbols)

    params =
      %{symbols: Enum.join(symbols, ",")}
      |> Utils.build_common_params(opts)

    http_opts = [params: params] ++ Keyword.take(opts, [:plug])

    Pagination.fetch_all("/stocks/quotes", http_opts, "quotes", &Quote.from_map/1)
  end
end
