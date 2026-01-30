defmodule AlpacaAPIClient.RequestBehaviour do
  @moduledoc """
  Behaviour for the HTTP client, enabling test mocking.
  """

  @callback get(String.t(), keyword()) :: {:ok, map()} | {:error, term()}
end
