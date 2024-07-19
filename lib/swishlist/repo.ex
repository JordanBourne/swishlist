defmodule Swishlist.Repo do
  use Ecto.Repo,
    otp_app: :swishlist,
    adapter: Ecto.Adapters.Postgres
end
