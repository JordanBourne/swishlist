import Config

config :swishlist, SwishlistWeb.Endpoint,
  url: [host: "swishlist.io", port: 443],
  check_origin: ["https://swishlist.io", "https://www.swishlist.io"],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Swishlist.Finch

config :logger, level: :info

config :moov_elixir_sdk,
  moov_public_key: System.get_env("MOOV_PUBLIC_KEY"),
  moov_private_key: System.get_env("MOOV_PRIVATE_KEY"),
  http_client: HTTPoison

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
