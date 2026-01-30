defmodule AlpacaAPIClient.Pagination do
  @moduledoc """
  Shared pagination logic for Alpaca Market Data endpoints.
  """

  @doc """
  Fetches all pages of a paginated endpoint.

  - `path` - the API path to request
  - `http_opts` - keyword list of HTTP options (must include `:params`)
  - `data_key` - the JSON key containing the data (e.g. "bars", "trades", "quotes")
  - `parser` - a function that parses a single raw data item into a struct
  """
  @spec fetch_all(String.t(), keyword(), String.t(), (map() -> struct())) ::
          {:ok, map()} | {:error, term()}
  def fetch_all(path, http_opts, data_key, parser) do
    fetch_all_pages(path, http_opts, data_key, parser, %{})
  end

  defp fetch_all_pages(path, http_opts, data_key, parser, acc) do
    case AlpacaAPIClient.Request.get(path, http_opts) do
      {:ok, body} ->
        data_map = body[data_key] || %{}

        acc =
          Enum.reduce(data_map, acc, fn {symbol, items}, acc ->
            parsed = Enum.map(items, parser)
            Map.update(acc, symbol, parsed, &(&1 ++ parsed))
          end)

        case body["next_page_token"] do
          nil ->
            {:ok, acc}

          token ->
            updated_params = Map.put(http_opts[:params], :page_token, token)
            updated_opts = Keyword.put(http_opts, :params, updated_params)
            fetch_all_pages(path, updated_opts, data_key, parser, acc)
        end

      {:error, _} = error ->
        error
    end
  end
end
