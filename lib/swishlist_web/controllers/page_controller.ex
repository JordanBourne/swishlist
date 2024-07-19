defmodule SwishlistWeb.PageController do
  use SwishlistWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
