defmodule AlpacaAPIClient.Utils do
  @moduledoc """
  Shared utility functions for the Alpaca API client.
  """

  @doc """
  Puts a key-value pair into a map only if the value is not nil.
  """
  @spec maybe_put(map(), atom(), term()) :: map()
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)

  @doc """
  Parses an ISO 8601 timestamp string into a DateTime.

  Raises an `ArgumentError` if the timestamp is invalid.
  """
  @spec parse_timestamp!(String.t()) :: DateTime.t()
  def parse_timestamp!(timestamp_string) do
    case DateTime.from_iso8601(timestamp_string) do
      {:ok, datetime, _offset} ->
        datetime

      {:error, reason} ->
        raise ArgumentError, "invalid timestamp #{inspect(timestamp_string)}: #{reason}"
    end
  end

  @doc """
  Builds a params map from opts for the common optional parameters
  shared across market data endpoints.
  """
  @spec build_common_params(map(), keyword()) :: map()
  def build_common_params(params, opts) do
    params
    |> maybe_put(:start, opts[:start])
    |> maybe_put(:end, opts[:end])
    |> maybe_put(:limit, opts[:limit])
    |> maybe_put(:feed, opts[:feed])
    |> maybe_put(:sort, opts[:sort])
  end
end
