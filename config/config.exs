import Config

config :alpaca_api_client, AlpacaAPIClient.Request,
  api_key: System.get_env("ALPACA_API_KEY_ID"),
  api_secret: System.get_env("ALPACA_API_SECRET_KEY")

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60, cleanup_interval_ms: 60_000 * 10]}

import_config "#{config_env()}.exs"
