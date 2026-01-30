defmodule AlpacaAPIClient.MarketData.BarsTest do
  use ExUnit.Case, async: false

  @moduletag :phase2

  alias AlpacaAPIClient.Types.Bar

  setup do
    Application.put_env(:alpaca_api_client, AlpacaAPIClient.Request,
      api_key: "test-key-id",
      api_secret: "test-secret-key"
    )

    Hammer.delete_buckets("alpaca_api")
    :ok
  end

  @fixture_bars %{
    "AAPL" => [
      %{
        "t" => "2024-01-02T05:00:00Z",
        "o" => 187.15,
        "h" => 188.44,
        "l" => 183.89,
        "c" => 185.64,
        "v" => 82_488_700,
        "n" => 1_003_126,
        "vw" => 185.9225
      },
      %{
        "t" => "2024-01-03T05:00:00Z",
        "o" => 184.22,
        "h" => 185.88,
        "l" => 183.43,
        "c" => 184.25,
        "v" => 58_414_500,
        "n" => 739_287,
        "vw" => 184.5603
      }
    ]
  }

  defp bars_response(bars, next_page_token \\ nil) do
    body = %{"bars" => bars}

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
    test "fetches bars for a single symbol" do
      plug = bars_response(@fixture_bars)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Bars.get(
                 symbols: ["AAPL"],
                 timeframe: "1Day",
                 plug: plug
               )

      assert map_size(result) == 1
      assert length(result["AAPL"]) == 2

      [bar1, _bar2] = result["AAPL"]
      assert %Bar{} = bar1
      assert bar1.open == 187.15
      assert bar1.close == 185.64
      assert bar1.volume == 82_488_700
    end

    test "fetches bars for multiple symbols" do
      multi_fixture =
        Map.put(@fixture_bars, "MSFT", [
          %{
            "t" => "2024-01-02T05:00:00Z",
            "o" => 373.0,
            "h" => 375.5,
            "l" => 371.0,
            "c" => 374.0,
            "v" => 20_000_000,
            "n" => 300_000,
            "vw" => 373.5
          }
        ])

      plug = bars_response(multi_fixture)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Bars.get(
                 symbols: ["AAPL", "MSFT"],
                 timeframe: "1Day",
                 plug: plug
               )

      assert map_size(result) == 2
      assert length(result["AAPL"]) == 2
      assert length(result["MSFT"]) == 1
    end

    test "handles pagination automatically" do
      page1_bars = %{
        "AAPL" => [
          %{
            "t" => "2024-01-02T05:00:00Z",
            "o" => 187.15,
            "h" => 188.44,
            "l" => 183.89,
            "c" => 185.64,
            "v" => 82_488_700,
            "n" => 1_003_126,
            "vw" => 185.9225
          }
        ]
      }

      page2_bars = %{
        "AAPL" => [
          %{
            "t" => "2024-01-03T05:00:00Z",
            "o" => 184.22,
            "h" => 185.88,
            "l" => 183.43,
            "c" => 184.25,
            "v" => 58_414_500,
            "n" => 739_287,
            "vw" => 184.5603
          }
        ]
      }

      # Use an agent to track which page we're on
      {:ok, agent} = Agent.start_link(fn -> 1 end)

      plug = fn conn ->
        page = Agent.get_and_update(agent, fn n -> {n, n + 1} end)

        {bars, token} =
          if page == 1,
            do: {page1_bars, "next_token_123"},
            else: {page2_bars, nil}

        body = %{"bars" => bars}
        body = if token, do: Map.put(body, "next_page_token", token), else: body

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(body))
      end

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Bars.get(
                 symbols: ["AAPL"],
                 timeframe: "1Day",
                 plug: plug
               )

      assert length(result["AAPL"]) == 2

      Agent.stop(agent)
    end

    test "parses timestamps as DateTime structs" do
      plug = bars_response(@fixture_bars)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Bars.get(
                 symbols: ["AAPL"],
                 timeframe: "1Day",
                 plug: plug
               )

      [bar | _] = result["AAPL"]
      assert %DateTime{} = bar.timestamp
      assert bar.timestamp == ~U[2024-01-02 05:00:00Z]
    end

    test "returns Bar structs with all fields" do
      plug = bars_response(@fixture_bars)

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Bars.get(
                 symbols: ["AAPL"],
                 timeframe: "1Day",
                 plug: plug
               )

      [bar | _] = result["AAPL"]
      assert bar.open == 187.15
      assert bar.high == 188.44
      assert bar.low == 183.89
      assert bar.close == 185.64
      assert bar.volume == 82_488_700
      assert bar.trade_count == 1_003_126
      assert bar.vwap == 185.9225
    end

    test "validates timeframe" do
      assert_raise ArgumentError, ~r/invalid timeframe/, fn ->
        AlpacaAPIClient.MarketData.Bars.get(
          symbols: ["AAPL"],
          timeframe: "invalid"
        )
      end
    end

    test "supports all valid timeframes" do
      plug = bars_response(@fixture_bars)

      for tf <- ~w(1Min 5Min 15Min 30Min 1Hour 4Hour 1Day 1Week 1Month) do
        assert {:ok, _} =
                 AlpacaAPIClient.MarketData.Bars.get(
                   symbols: ["AAPL"],
                   timeframe: tf,
                   plug: plug
                 )
      end
    end

    test "passes optional params" do
      plug = fn conn ->
        query = conn.query_string
        assert query =~ "start="
        assert query =~ "end="
        assert query =~ "limit="
        assert query =~ "adjustment="
        assert query =~ "feed="
        assert query =~ "sort="

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"bars" => %{}}))
      end

      assert {:ok, _} =
               AlpacaAPIClient.MarketData.Bars.get(
                 symbols: ["AAPL"],
                 timeframe: "1Day",
                 start: "2024-01-01T00:00:00Z",
                 end: "2024-01-31T00:00:00Z",
                 limit: 100,
                 adjustment: "split",
                 feed: "sip",
                 sort: "asc",
                 plug: plug
               )
    end

    test "propagates HTTP errors" do
      plug = fn conn ->
        Plug.Conn.send_resp(conn, 401, "")
      end

      assert {:error, :unauthorized} =
               AlpacaAPIClient.MarketData.Bars.get(
                 symbols: ["AAPL"],
                 timeframe: "1Day",
                 plug: plug
               )
    end
  end
end
