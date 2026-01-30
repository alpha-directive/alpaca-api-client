defmodule AlpacaAPIClient.MarketData.SnapshotsTest do
  use ExUnit.Case, async: false

  @moduletag :phase4

  alias AlpacaAPIClient.Types.{Bar, Quote, Snapshot, Trade}

  setup do
    Application.put_env(:alpaca_api_client, AlpacaAPIClient.Request,
      api_key: "test-key-id",
      api_secret: "test-secret-key"
    )

    Hammer.delete_buckets("alpaca_api")
    :ok
  end

  @trade_fixture %{
    "t" => "2024-01-02T14:30:00Z",
    "x" => "V",
    "p" => 187.15,
    "s" => 100,
    "c" => ["@"],
    "z" => "C",
    "i" => 12_345
  }

  @quote_fixture %{
    "t" => "2024-01-02T14:30:00Z",
    "ax" => "Q",
    "ap" => 187.20,
    "as" => 300,
    "bx" => "V",
    "bp" => 187.15,
    "bs" => 200,
    "c" => ["R"],
    "z" => "C"
  }

  @bar_fixture %{
    "t" => "2024-01-02T05:00:00Z",
    "o" => 187.15,
    "h" => 188.44,
    "l" => 183.89,
    "c" => 185.64,
    "v" => 82_488_700,
    "n" => 1_003_126,
    "vw" => 185.9225
  }

  defp json_plug(body) do
    fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(body))
    end
  end

  describe "latest_trades/1" do
    test "fetches latest trades for symbols" do
      plug = json_plug(%{"trades" => %{"AAPL" => @trade_fixture}})

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.latest_trades(
                 symbols: ["AAPL"],
                 plug: plug
               )

      assert %Trade{} = result["AAPL"]
      assert result["AAPL"].price == 187.15
    end

    test "fetches latest trades for multiple symbols" do
      plug =
        json_plug(%{
          "trades" => %{
            "AAPL" => @trade_fixture,
            "MSFT" => Map.put(@trade_fixture, "p", 373.0)
          }
        })

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.latest_trades(
                 symbols: ["AAPL", "MSFT"],
                 plug: plug
               )

      assert map_size(result) == 2
      assert result["MSFT"].price == 373.0
    end
  end

  describe "latest_quotes/1" do
    test "fetches latest quotes for symbols" do
      plug = json_plug(%{"quotes" => %{"AAPL" => @quote_fixture}})

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.latest_quotes(
                 symbols: ["AAPL"],
                 plug: plug
               )

      assert %Quote{} = result["AAPL"]
      assert result["AAPL"].ask_price == 187.20
      assert result["AAPL"].bid_price == 187.15
    end

    test "fetches latest quotes for multiple symbols" do
      plug =
        json_plug(%{
          "quotes" => %{
            "AAPL" => @quote_fixture,
            "MSFT" => Map.put(@quote_fixture, "ap", 375.0)
          }
        })

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.latest_quotes(
                 symbols: ["AAPL", "MSFT"],
                 plug: plug
               )

      assert map_size(result) == 2
    end
  end

  describe "latest_bars/1" do
    test "fetches latest bars for symbols" do
      plug = json_plug(%{"bars" => %{"AAPL" => @bar_fixture}})

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.latest_bars(
                 symbols: ["AAPL"],
                 plug: plug
               )

      assert %Bar{} = result["AAPL"]
      assert result["AAPL"].open == 187.15
    end

    test "fetches latest bars for multiple symbols" do
      plug =
        json_plug(%{
          "bars" => %{
            "AAPL" => @bar_fixture,
            "MSFT" => Map.put(@bar_fixture, "o", 373.0)
          }
        })

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.latest_bars(
                 symbols: ["AAPL", "MSFT"],
                 plug: plug
               )

      assert map_size(result) == 2
      assert result["MSFT"].open == 373.0
    end
  end

  describe "get/1 (snapshots)" do
    test "fetches snapshots for a single symbol" do
      plug =
        json_plug(%{
          "AAPL" => %{
            "latestTrade" => @trade_fixture,
            "latestQuote" => @quote_fixture,
            "minuteBar" => @bar_fixture,
            "dailyBar" => @bar_fixture,
            "prevDailyBar" => @bar_fixture
          }
        })

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.get(
                 symbols: ["AAPL"],
                 plug: plug
               )

      assert %Snapshot{} = result["AAPL"]
      assert %Trade{} = result["AAPL"].latest_trade
      assert %Quote{} = result["AAPL"].latest_quote
      assert %Bar{} = result["AAPL"].minute_bar
      assert %Bar{} = result["AAPL"].daily_bar
      assert %Bar{} = result["AAPL"].prev_daily_bar
    end

    test "fetches snapshots for multiple symbols" do
      plug =
        json_plug(%{
          "AAPL" => %{
            "latestTrade" => @trade_fixture,
            "latestQuote" => @quote_fixture,
            "minuteBar" => @bar_fixture,
            "dailyBar" => @bar_fixture,
            "prevDailyBar" => @bar_fixture
          },
          "MSFT" => %{
            "latestTrade" => Map.put(@trade_fixture, "p", 373.0),
            "latestQuote" => @quote_fixture,
            "minuteBar" => @bar_fixture,
            "dailyBar" => @bar_fixture,
            "prevDailyBar" => @bar_fixture
          }
        })

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.get(
                 symbols: ["AAPL", "MSFT"],
                 plug: plug
               )

      assert map_size(result) == 2
      assert result["MSFT"].latest_trade.price == 373.0
    end

    test "handles nil fields in snapshot" do
      plug =
        json_plug(%{
          "AAPL" => %{
            "latestTrade" => @trade_fixture,
            "latestQuote" => nil,
            "minuteBar" => nil,
            "dailyBar" => @bar_fixture,
            "prevDailyBar" => nil
          }
        })

      assert {:ok, result} =
               AlpacaAPIClient.MarketData.Snapshots.get(
                 symbols: ["AAPL"],
                 plug: plug
               )

      assert result["AAPL"].latest_trade != nil
      assert result["AAPL"].latest_quote == nil
      assert result["AAPL"].minute_bar == nil
      assert result["AAPL"].daily_bar != nil
      assert result["AAPL"].prev_daily_bar == nil
    end
  end

  describe "error handling" do
    test "propagates HTTP errors for all endpoints" do
      plug = fn conn -> Plug.Conn.send_resp(conn, 401, "") end

      assert {:error, :unauthorized} =
               AlpacaAPIClient.MarketData.Snapshots.latest_trades(symbols: ["AAPL"], plug: plug)

      assert {:error, :unauthorized} =
               AlpacaAPIClient.MarketData.Snapshots.latest_quotes(symbols: ["AAPL"], plug: plug)

      assert {:error, :unauthorized} =
               AlpacaAPIClient.MarketData.Snapshots.latest_bars(symbols: ["AAPL"], plug: plug)

      assert {:error, :unauthorized} =
               AlpacaAPIClient.MarketData.Snapshots.get(symbols: ["AAPL"], plug: plug)
    end
  end
end
