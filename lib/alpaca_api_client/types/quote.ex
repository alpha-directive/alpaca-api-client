defmodule AlpacaAPIClient.Types.Quote do
  @moduledoc """
  Typed struct representing a historical quote.
  """

  alias AlpacaAPIClient.Utils

  @type t :: %__MODULE__{
          timestamp: DateTime.t(),
          ask_exchange: String.t(),
          ask_price: float(),
          ask_size: non_neg_integer(),
          bid_exchange: String.t(),
          bid_price: float(),
          bid_size: non_neg_integer(),
          conditions: [String.t()],
          tape: String.t()
        }

  @enforce_keys [
    :timestamp,
    :ask_exchange,
    :ask_price,
    :ask_size,
    :bid_exchange,
    :bid_price,
    :bid_size,
    :conditions,
    :tape
  ]
  defstruct [
    :timestamp,
    :ask_exchange,
    :ask_price,
    :ask_size,
    :bid_exchange,
    :bid_price,
    :bid_size,
    :conditions,
    :tape
  ]

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      timestamp: Utils.parse_timestamp!(map["t"]),
      ask_exchange: map["ax"],
      ask_price: map["ap"] / 1,
      ask_size: map["as"],
      bid_exchange: map["bx"],
      bid_price: map["bp"] / 1,
      bid_size: map["bs"],
      conditions: map["c"] || [],
      tape: map["z"]
    }
  end
end
