defmodule AlpacaAPIClient.Types.CalendarDay do
  @moduledoc """
  Typed struct representing a market calendar day with trading hours.
  """

  @type t :: %__MODULE__{
          date: Date.t(),
          open: Time.t(),
          close: Time.t(),
          session_open: Time.t(),
          session_close: Time.t(),
          settlement_date: Date.t()
        }

  @enforce_keys [:date, :open, :close, :session_open, :session_close, :settlement_date]
  defstruct [:date, :open, :close, :session_open, :session_close, :settlement_date]

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      date: Date.from_iso8601!(map["date"]),
      open: parse_time!(map["open"]),
      close: parse_time!(map["close"]),
      session_open: parse_time!(map["session_open"]),
      session_close: parse_time!(map["session_close"]),
      settlement_date: Date.from_iso8601!(map["settlement_date"])
    }
  end

  defp parse_time!(<<h::binary-size(2), ":", m::binary-size(2)>>), do: Time.new!(String.to_integer(h), String.to_integer(m), 0)
  defp parse_time!(<<h::binary-size(2), m::binary-size(2)>>), do: Time.new!(String.to_integer(h), String.to_integer(m), 0)
  defp parse_time!(other), do: Time.from_iso8601!(other)
end
