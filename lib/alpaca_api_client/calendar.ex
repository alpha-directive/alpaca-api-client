defmodule AlpacaAPIClient.Calendar do
  @moduledoc """
  Calendar endpoint for the Alpaca Trading API.

  Returns trading days and market hours. The calendar API serves the full list
  of market days from 1970 to 2029, including open/close times and early closures.

  GET /v2/calendar

  ## Options

    * `:start` - Start date to filter results (string, "YYYY-MM-DD"). Optional.
    * `:end` - End date to filter results (string, "YYYY-MM-DD"). Optional.
    * `:date_type` - Type of date to filter by: `"TRADING"` or `"SETTLEMENT"`. Optional.
    * `:plug` - Test plug for HTTP mocking. Optional.

  ## Examples

      # Fetch all trading days
      AlpacaAPIClient.calendar([])

      # Fetch trading days in a date range
      AlpacaAPIClient.calendar(start: "2024-01-01", end: "2024-01-31")
  """

  alias AlpacaAPIClient.Utils
  alias AlpacaAPIClient.Types.CalendarDay

  @trading_base_url "https://api.alpaca.markets/v2"

  @spec get(keyword()) :: {:ok, [CalendarDay.t()]} | {:error, term()}
  def get(opts \\ []) do
    params =
      %{}
      |> Utils.maybe_put(:start, opts[:start])
      |> Utils.maybe_put(:end, opts[:end])
      |> Utils.maybe_put(:date_type, opts[:date_type])

    http_opts =
      [params: params, base_url: base_url()]
      |> maybe_add_plug(opts)

    case AlpacaAPIClient.Request.get("/calendar", http_opts) do
      {:ok, body} when is_list(body) ->
        calendar_days = Enum.map(body, &CalendarDay.from_map/1)
        {:ok, calendar_days}

      {:error, _} = error ->
        error
    end
  end

  defp base_url do
    config = Application.get_env(:alpaca_api_client, __MODULE__, [])
    config[:base_url] || @trading_base_url
  end

  defp maybe_add_plug(http_opts, opts) do
    case opts[:plug] do
      nil -> http_opts
      plug -> Keyword.put(http_opts, :plug, plug)
    end
  end
end
