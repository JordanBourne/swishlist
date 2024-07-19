defmodule SwishlistWeb.WishlistController do
  use SwishlistWeb, :controller

  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    live_render(conn, :index)
  end
end
