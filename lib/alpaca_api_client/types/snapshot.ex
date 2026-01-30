defmodule AlpacaAPIClient.Types.Snapshot do
  @moduledoc """
  Typed struct representing a stock snapshot.
  """

  alias AlpacaAPIClient.Types.{Bar, Quote, Trade}

  @type t :: %__MODULE__{
          latest_trade: Trade.t() | nil,
          latest_quote: Quote.t() | nil,
          minute_bar: Bar.t() | nil,
          daily_bar: Bar.t() | nil,
          prev_daily_bar: Bar.t() | nil
        }

  defstruct [:latest_trade, :latest_quote, :minute_bar, :daily_bar, :prev_daily_bar]

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      latest_trade: parse_if_present(map["latestTrade"], &Trade.from_map/1),
      latest_quote: parse_if_present(map["latestQuote"], &Quote.from_map/1),
      minute_bar: parse_if_present(map["minuteBar"], &Bar.from_map/1),
      daily_bar: parse_if_present(map["dailyBar"], &Bar.from_map/1),
      prev_daily_bar: parse_if_present(map["prevDailyBar"], &Bar.from_map/1)
    }
  end

  defp parse_if_present(nil, _fun), do: nil
  defp parse_if_present(data, fun), do: fun.(data)
end
