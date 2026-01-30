defmodule AlpacaAPIClient.MarketData.TradesTest do
  use ExUnit.Case, async: false

  @moduletag :phase3

  alias AlpacaAPIClient.Types.Trade

  setup do
    Application.put_env(:alpaca_api_client, AlpacaAPIClient.Request,
      api_key: "test-key-id",
      api_secret: "test-secret-key"
    )

    Hammer.delete_buckets("alpaca_api")
    :ok
  end

  @fixture_trades %{
    "AAPL" => [
      %{
        "t" => "2024-01-02T14:30:00.123456Z",
        "x" => "V",
        "p" => 187.15,
        "s" => 100,
        "c" => ["@", "T"],
        "z" => "C",
        "i" => 12_345_678
      },
      %{
        "t" => "2024-01-02T14:30:01.654321Z",
        "x" => "Q",
        "p" => 187.20,
        "s" => 50,
        "c" => ["@"],
        "z" => "C",
        "i" => 12_345_679
      }
    ]
  }

  defp trades_response(trades, next_page_token \\ nil) do
    body = %{"trades" => trades}

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
    test "fetches trades for a single symbol" do
      plug = trades_response(@fixture_trades)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Trades.get(
                 symbols: ["AAPL"],
                 plug: plug
               )

      assert length(result["AAPL"]) == 2
      [trade | _] = result["AAPL"]
      assert %Trade{} = trade
      assert trade.price == 187.15
      assert trade.size == 100
      assert trade.exchange == "V"
      assert trade.conditions == ["@", "T"]
      assert trade.tape == "C"
      assert trade.trade_id == 12_345_678
    end

    test "fetches trades for multiple symbols" do
      multi =
        Map.put(@fixture_trades, "MSFT", [
          %{
            "t" => "2024-01-02T14:30:00Z",
            "x" => "Q",
            "p" => 373.0,
            "s" => 200,
            "c" => ["@"],
            "z" => "C",
            "i" => 99_999
          }
        ])

      plug = trades_response(multi)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Trades.get(
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

        {trades, token} =
          if page == 1 do
            {%{"AAPL" => [hd(@fixture_trades["AAPL"])]}, "next_token"}
          else
            {%{"AAPL" => [List.last(@fixture_trades["AAPL"])]}, nil}
          end

        body = %{"trades" => trades}
        body = if token, do: Map.put(body, "next_page_token", token), else: body

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(body))
      end

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Trades.get(symbols: ["AAPL"], plug: plug)

      assert length(result["AAPL"]) == 2
      Agent.stop(agent)
    end

    test "parses timestamps as DateTime structs" do
      plug = trades_response(@fixture_trades)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Trades.get(symbols: ["AAPL"], plug: plug)

      [trade | _] = result["AAPL"]
      assert %DateTime{} = trade.timestamp
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
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"trades" => %{}}))
      end

      assert {:ok, _} =
               AlpacaAPIClient.MarketData.Trades.get(
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
               AlpacaAPIClient.MarketData.Trades.get(symbols: ["AAPL"], plug: plug)
    end
  end
end
