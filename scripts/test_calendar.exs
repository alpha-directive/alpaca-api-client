# Script to test the Calendar endpoint against the live Alpaca API.
#
# Requires ALPACA_API_KEY_ID and ALPACA_API_SECRET_KEY environment variables.
#
# Usage:
#   mix run scripts/test_calendar.exs

alias AlpacaAPIClient.Types.CalendarDay

api_key = System.get_env("ALPACA_API_KEY_ID")
api_secret = System.get_env("ALPACA_API_SECRET_KEY")

unless api_key && api_secret do
  IO.puts("Error: ALPACA_API_KEY_ID and ALPACA_API_SECRET_KEY must be set")
  System.halt(1)
end

Application.put_env(:alpaca_api_client, AlpacaAPIClient.Request,
  api_key: api_key,
  api_secret: api_secret
)

IO.puts("=== Alpaca Calendar API Test ===\n")

# Test 1: Fetch a small date range
IO.puts("--- Fetching calendar for Jan 2024 ---")

case AlpacaAPIClient.calendar(start: "2024-01-01", end: "2024-01-31") do
  {:ok, days} ->
    IO.puts("Got #{length(days)} trading days\n")

    for %CalendarDay{} = day <- days do
      IO.puts(
        "  #{day.date}  open=#{day.open} close=#{day.close}  " <>
          "session=#{day.session_open}-#{day.session_close}  " <>
          "settlement=#{day.settlement_date}"
      )
    end

  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end

# Test 2: Fetch today's calendar
IO.puts("\n--- Fetching today's calendar ---")
today = Date.utc_today() |> Date.to_iso8601()

case AlpacaAPIClient.calendar(start: today, end: today) do
  {:ok, [day]} ->
    IO.puts("  Today (#{day.date}) is a trading day")
    IO.puts("  Market hours: #{day.open} - #{day.close}")
    IO.puts("  Extended hours: #{day.session_open} - #{day.session_close}")

  {:ok, []} ->
    IO.puts("  Today (#{today}) is not a trading day")

  {:error, reason} ->
    IO.puts("  Error: #{inspect(reason)}")
end

# Test 3: Fetch next 5 trading days
IO.puts("\n--- Next 5 trading days ---")
future = Date.utc_today() |> Date.add(30) |> Date.to_iso8601()

case AlpacaAPIClient.calendar(start: today, end: future) do
  {:ok, days} ->
    days
    |> Enum.take(5)
    |> Enum.each(fn day ->
      IO.puts("  #{day.date}  #{day.open}-#{day.close}")
    end)

  {:error, reason} ->
    IO.puts("  Error: #{inspect(reason)}")
end

IO.puts("\nDone.")
