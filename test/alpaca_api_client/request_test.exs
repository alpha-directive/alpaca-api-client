defmodule AlpacaAPIClient.RequestTest do
  use ExUnit.Case, async: false

  @moduletag :phase1

  setup do
    Application.put_env(:alpaca_api_client, AlpacaAPIClient.Request,
      api_key: "test-key-id",
      api_secret: "test-secret-key"
    )

    :ok
  end

  defp plug_200(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(200, Jason.encode!(%{"bars" => []}))
  end

  defp plug_status(conn, status) do
    Plug.Conn.send_resp(conn, status, "")
  end

  defp plug_500(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(500, Jason.encode!(%{"message" => "internal error"}))
  end

  describe "get/2" do
    test "returns {:ok, body} on successful response" do
      assert {:ok, %{"bars" => []}} =
               AlpacaAPIClient.Request.get("/stocks/bars", plug: &plug_200/1)
    end

    test "sends authentication headers" do
      plug = fn conn ->
        key = Plug.Conn.get_req_header(conn, "alpaca-api-key-id")
        secret = Plug.Conn.get_req_header(conn, "alpaca-api-secret-key")

        assert key == ["test-key-id"]
        assert secret == ["test-secret-key"]

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, Jason.encode!(%{"ok" => true}))
      end

      assert {:ok, %{"ok" => true}} =
               AlpacaAPIClient.Request.get("/test", plug: plug)
    end

    test "returns {:error, :unauthorized} on 401" do
      assert {:error, :unauthorized} =
               AlpacaAPIClient.Request.get("/test", plug: &plug_status(&1, 401))
    end

    test "returns {:error, :forbidden} on 403" do
      assert {:error, :forbidden} =
               AlpacaAPIClient.Request.get("/test", plug: &plug_status(&1, 403))
    end

    test "returns {:error, :not_found} on 404" do
      assert {:error, :not_found} =
               AlpacaAPIClient.Request.get("/test", plug: &plug_status(&1, 404))
    end

    test "returns {:error, :rate_limited} on 429" do
      assert {:error, :rate_limited} =
               AlpacaAPIClient.Request.get("/test", plug: &plug_status(&1, 429))
    end

    test "returns {:error, {:server_error, 500, _}} on 500" do
      assert {:error, {:server_error, 500, _body}} =
               AlpacaAPIClient.Request.get("/test", plug: &plug_500/1)
    end
  end
end
