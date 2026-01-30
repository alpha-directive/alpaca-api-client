defmodule AlpacaAPIClient.Types.Bar do
  @moduledoc """
  Typed struct representing a historical bar (OHLCV candle).
  """

  alias AlpacaAPIClient.Utils

  @type t :: %__MODULE__{
          timestamp: DateTime.t(),
          open: float(),
          high: float(),
          low: float(),
          close: float(),
          volume: non_neg_integer(),
          trade_count: non_neg_integer(),
          vwap: float()
        }

  @enforce_keys [:timestamp, :open, :high, :low, :close, :volume, :trade_count, :vwap]
  defstruct [:timestamp, :open, :high, :low, :close, :volume, :trade_count, :vwap]

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      timestamp: Utils.parse_timestamp!(map["t"]),
      open: map["o"] / 1,
      high: map["h"] / 1,
      low: map["l"] / 1,
      close: map["c"] / 1,
      volume: map["v"],
      trade_count: map["n"],
      vwap: map["vw"] / 1
    }
  end
end
