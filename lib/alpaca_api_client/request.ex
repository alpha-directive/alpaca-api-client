defmodule AlpacaAPIClient.Request do
  @moduledoc """
  Core HTTP client for the Alpaca Markets API.

  Handles authentication, rate limiting, and error handling.
  """

  @behaviour AlpacaAPIClient.RequestBehaviour

  @base_url "https://data.alpaca.markets/v2"
  @rate_limit_bucket "alpaca_api"
  @rate_limit_max 200
  @rate_limit_window_ms 60_000

  @impl true
  def get(path, opts \\ []) do
    with :ok <- check_rate_limit(),
         {:ok, response} <- do_request(path, opts) do
      handle_response(response)
    end
  end

  defp check_rate_limit do
    case Hammer.check_rate(@rate_limit_bucket, @rate_limit_window_ms, @rate_limit_max) do
      {:allow, _count} -> :ok
      {:deny, _limit} -> {:error, :rate_limited}
    end
  end

  defp do_request(path, opts) do
    config = config()
    url = (config[:base_url] || @base_url) <> path
    params = opts[:params] || %{}

    headers = [
      {"ALPACA-API-KEY-ID", config[:api_key]},
      {"ALPACA-API-SECRET-KEY", config[:api_secret]}
    ]

    req_opts =
      [url: url, headers: headers, params: params, retry: false]
      |> maybe_add_plug(opts)

    case Req.get(req_opts) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, {:request_failed, reason}}
    end
  end

  defp maybe_add_plug(req_opts, opts) do
    case opts[:plug] do
      nil -> req_opts
      plug -> Keyword.put(req_opts, :plug, plug)
    end
  end

  defp handle_response(%Req.Response{status: status, body: body}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response(%Req.Response{status: 401}) do
    {:error, :unauthorized}
  end

  defp handle_response(%Req.Response{status: 403}) do
    {:error, :forbidden}
  end

  defp handle_response(%Req.Response{status: 404}) do
    {:error, :not_found}
  end

  defp handle_response(%Req.Response{status: 422, body: body}) do
    {:error, {:unprocessable_entity, body}}
  end

  defp handle_response(%Req.Response{status: 429}) do
    {:error, :rate_limited}
  end

  defp handle_response(%Req.Response{status: status, body: body})
       when status >= 400 and status <= 499 do
    {:error, {:client_error, status, body}}
  end

  defp handle_response(%Req.Response{status: status, body: body}) when status >= 500 do
    {:error, {:server_error, status, body}}
  end

  defp handle_response(%Req.Response{status: status, body: body}) do
    {:error, {:unexpected_status, status, body}}
  end

  defp config do
    Application.get_env(:alpaca_api_client, __MODULE__, [])
  end
end
