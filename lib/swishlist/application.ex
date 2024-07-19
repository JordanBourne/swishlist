defmodule Swishlist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SwishlistWeb.Telemetry,
      # Start the Ecto repository
      Swishlist.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Swishlist.PubSub},
      # Start Finch
      {Finch, name: Swishlist.Finch},
      # Start the Endpoint (http/https)
      SwishlistWeb.Endpoint
      # Start a worker by calling: Swishlist.Worker.start_link(arg)
      # {Swishlist.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Swishlist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SwishlistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
