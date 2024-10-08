import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :swishlist, Swishlist.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "swishlist_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :swishlist, SwishlistWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0hxM8q4oPUyg1FVb/ecTdHDX1ie1spAlP9I0OYrMQYp6q+2zDHqD4BJ5HhqbBNEx",
  server: false

# In test we don't send emails.
config :swishlist, Swishlist.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :moov_elixir_sdk,
  moov_public_key: System.get_env("MOOV_PUBLIC_KEY"),
  moov_private_key: System.get_env("MOOV_PRIVATE_KEY"),
  http_client: HTTPoison
