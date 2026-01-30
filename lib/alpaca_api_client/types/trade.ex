defmodule AlpacaAPIClient.Types.Trade do
  @moduledoc """
  Typed struct representing a historical trade.
  """

  alias AlpacaAPIClient.Utils

  @type t :: %__MODULE__{
          timestamp: DateTime.t(),
          exchange: String.t(),
          price: float(),
          size: non_neg_integer(),
          conditions: [String.t()],
          tape: String.t(),
          trade_id: integer()
        }

  @enforce_keys [:timestamp, :exchange, :price, :size, :conditions, :tape, :trade_id]
  defstruct [:timestamp, :exchange, :price, :size, :conditions, :tape, :trade_id]

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      timestamp: Utils.parse_timestamp!(map["t"]),
      exchange: map["x"],
      price: map["p"] / 1,
      size: map["s"],
      conditions: map["c"] || [],
      tape: map["z"],
      trade_id: map["i"]
    }
  end
end
