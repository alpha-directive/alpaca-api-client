import Config

config :alpaca_api_client, AlpacaAPIClient.Request,
  api_key: System.get_env("ALPACA_API_KEY_ID"),
  api_secret: System.get_env("ALPACA_API_SECRET_KEY")

import_config "#{config_env()}.exs"
