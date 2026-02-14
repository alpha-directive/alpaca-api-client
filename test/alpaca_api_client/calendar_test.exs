defmodule AlpacaAPIClient.CalendarTest do
  use ExUnit.Case, async: false

  alias AlpacaAPIClient.Types.CalendarDay

  setup do
    Application.put_env(:alpaca_api_client, AlpacaAPIClient.Request,
      api_key: "test-key-id",
      api_secret: "test-secret-key"
    )

    :ok
  end

  @fixture_calendar [
    %{
      "date" => "2024-01-02",
      "open" => "09:30",
      "close" => "16:00",
      "session_open" => "0400",
      "session_close" => "2000",
      "settlement_date" => "2024-01-04"
    },
    %{
      "date" => "2024-01-03",
      "open" => "09:30",
      "close" => "16:00",
      "session_open" => "0400",
      "session_close" => "2000",
      "settlement_date" => "2024-01-05"
    }
  ]

  @early_close_fixture [
    %{
      "date" => "2024-11-29",
      "open" => "09:30",
      "close" => "13:00",
      "session_open" => "0400",
      "session_close" => "1700",
      "settlement_date" => "2024-12-03"
    }
  ]

  defp calendar_response(calendar_days) do
    fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(calendar_days))
    end
  end

  describe "get/1" do
    test "fetches calendar days" do
      plug = calendar_response(@fixture_calendar)

      assert {:ok, result} = AlpacaAPIClient.Calendar.get(plug: plug)

      assert length(result) == 2
      assert [%CalendarDay{} = day1, %CalendarDay{} = day2] = result
      assert day1.date == ~D[2024-01-02]
      assert day2.date == ~D[2024-01-03]
    end

    test "parses dates as Date structs" do
      plug = calendar_response(@fixture_calendar)

      assert {:ok, [day | _]} = AlpacaAPIClient.Calendar.get(plug: plug)

      assert %Date{} = day.date
      assert day.date == ~D[2024-01-02]
      assert %Date{} = day.settlement_date
      assert day.settlement_date == ~D[2024-01-04]
    end

    test "parses times as Time structs" do
      plug = calendar_response(@fixture_calendar)

      assert {:ok, [day | _]} = AlpacaAPIClient.Calendar.get(plug: plug)

      assert %Time{} = day.open
      assert day.open == ~T[09:30:00]
      assert %Time{} = day.close
      assert day.close == ~T[16:00:00]
      assert %Time{} = day.session_open
      assert day.session_open == ~T[04:00:00]
      assert %Time{} = day.session_close
      assert day.session_close == ~T[20:00:00]
    end

    test "returns CalendarDay structs with all fields" do
      plug = calendar_response(@fixture_calendar)

      assert {:ok, [day | _]} = AlpacaAPIClient.Calendar.get(plug: plug)

      assert day.date == ~D[2024-01-02]
      assert day.open == ~T[09:30:00]
      assert day.close == ~T[16:00:00]
      assert day.session_open == ~T[04:00:00]
      assert day.session_close == ~T[20:00:00]
      assert day.settlement_date == ~D[2024-01-04]
    end

    test "handles early close days" do
      plug = calendar_response(@early_close_fixture)

      assert {:ok, [day]} = AlpacaAPIClient.Calendar.get(plug: plug)

      assert day.date == ~D[2024-11-29]
      assert day.close == ~T[13:00:00]
      assert day.session_close == ~T[17:00:00]
    end

    test "passes optional start and end params" do
      plug = fn conn ->
        query = conn.query_string
        assert query =~ "start="
        assert query =~ "end="

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!([]))
      end

      assert {:ok, []} =
               AlpacaAPIClient.Calendar.get(
                 start: "2024-01-01",
                 end: "2024-01-31",
                 plug: plug
               )
    end

    test "passes date_type param" do
      plug = fn conn ->
        query = conn.query_string
        assert query =~ "date_type=SETTLEMENT"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!([]))
      end

      assert {:ok, []} =
               AlpacaAPIClient.Calendar.get(
                 date_type: "SETTLEMENT",
                 plug: plug
               )
    end

    test "returns empty list when no trading days" do
      plug = calendar_response([])

      assert {:ok, []} = AlpacaAPIClient.Calendar.get(plug: plug)
    end

    test "propagates HTTP errors" do
      plug = fn conn ->
        Plug.Conn.send_resp(conn, 401, "")
      end

      assert {:error, :unauthorized} = AlpacaAPIClient.Calendar.get(plug: plug)
    end
  end
end
