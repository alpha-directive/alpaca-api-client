defmodule AlpacaAPIClient.MarketData.QuotesTest do
  use ExUnit.Case, async: false

  @moduletag :phase3

  alias AlpacaAPIClient.Types.Quote

  setup do
    Application.put_env(:alpaca_api_client, AlpacaAPIClient.Request,
      api_key: "test-key-id",
      api_secret: "test-secret-key"
    )

    :ok
  end

  @fixture_quotes %{
    "AAPL" => [
      %{
        "t" => "2024-01-02T14:30:00.123456Z",
        "ax" => "Q",
        "ap" => 187.20,
        "as" => 300,
        "bx" => "V",
        "bp" => 187.15,
        "bs" => 200,
        "c" => ["R"],
        "z" => "C"
      },
      %{
        "t" => "2024-01-02T14:30:01.654321Z",
        "ax" => "P",
        "ap" => 187.25,
        "as" => 100,
        "bx" => "Q",
        "bp" => 187.18,
        "bs" => 400,
        "c" => ["R"],
        "z" => "C"
      }
    ]
  }

  defp quotes_response(quotes, next_page_token \\ nil) do
    body = %{"quotes" => quotes}

    body =
      if next_page_token,
        do: Map.put(body, "next_page_token", next_page_token),
        else: body

    fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(body))
    end
  end

  describe "get/1" do
    test "fetches quotes for a single symbol" do
      plug = quotes_response(@fixture_quotes)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Quotes.get(
                 symbols: ["AAPL"],
                 plug: plug
               )

      assert length(result["AAPL"]) == 2
      [quote_data | _] = result["AAPL"]
      assert %Quote{} = quote_data
      assert quote_data.ask_price == 187.20
      assert quote_data.ask_size == 300
      assert quote_data.ask_exchange == "Q"
      assert quote_data.bid_price == 187.15
      assert quote_data.bid_size == 200
      assert quote_data.bid_exchange == "V"
      assert quote_data.conditions == ["R"]
      assert quote_data.tape == "C"
    end

    test "fetches quotes for multiple symbols" do
      multi =
        Map.put(@fixture_quotes, "MSFT", [
          %{
            "t" => "2024-01-02T14:30:00Z",
            "ax" => "Q",
            "ap" => 375.0,
            "as" => 100,
            "bx" => "P",
            "bp" => 374.95,
            "bs" => 200,
            "c" => ["R"],
            "z" => "C"
          }
        ])

      plug = quotes_response(multi)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Quotes.get(
                 symbols: ["AAPL", "MSFT"],
                 plug: plug
               )

      assert map_size(result) == 2
      assert length(result["MSFT"]) == 1
    end

    test "handles pagination automatically" do
      {:ok, agent} = Agent.start_link(fn -> 1 end)

      plug = fn conn ->
        page = Agent.get_and_update(agent, fn n -> {n, n + 1} end)

        {quotes, token} =
          if page == 1 do
            {%{"AAPL" => [hd(@fixture_quotes["AAPL"])]}, "next_token"}
          else
            {%{"AAPL" => [List.last(@fixture_quotes["AAPL"])]}, nil}
          end

        body = %{"quotes" => quotes}
        body = if token, do: Map.put(body, "next_page_token", token), else: body

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(body))
      end

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Quotes.get(symbols: ["AAPL"], plug: plug)

      assert length(result["AAPL"]) == 2
      Agent.stop(agent)
    end

    test "parses timestamps as DateTime structs" do
      plug = quotes_response(@fixture_quotes)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Quotes.get(symbols: ["AAPL"], plug: plug)

      [quote_data | _] = result["AAPL"]
      assert %DateTime{} = quote_data.timestamp
    end

    test "passes optional params" do
      plug = fn conn ->
        query = conn.query_string
        assert query =~ "start="
        assert query =~ "end="
        assert query =~ "limit="
        assert query =~ "feed="
        assert query =~ "sort="

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"quotes" => %{}}))
      end

      assert {:ok, _} =
               AlpacaAPIClient.MarketData.Quotes.get(
                 symbols: ["AAPL"],
                 start: "2024-01-01T00:00:00Z",
                 end: "2024-01-31T00:00:00Z",
                 limit: 100,
                 feed: "sip",
                 sort: "asc",
                 plug: plug
               )
    end

    test "propagates HTTP errors" do
      plug = fn conn -> Plug.Conn.send_resp(conn, 401, "") end

      assert {:error, :unauthorized} =
               AlpacaAPIClient.MarketData.Quotes.get(symbols: ["AAPL"], plug: plug)
    end
  end
end
