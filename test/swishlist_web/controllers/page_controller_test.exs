defmodule SwishlistWeb.PageControllerTest do
  use SwishlistWeb.ConnCase

  import Swishlist.AccountsFixtures

  test "GET / while not authenticated", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Create Your Wishlist"
    assert html_response(conn, 200) =~ "SWISHLIST"
    assert html_response(conn, 200) =~ "Register"
    assert html_response(conn, 200) =~ "Log in"
  end

  test "GET / while authenticated", %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture())
      |> get(~p"/")

    assert html_response(conn, 200) =~ "Create Your Wishlist"
    assert html_response(conn, 200) =~ "SWISHLIST"
    assert html_response(conn, 200) =~ "Settings"
    assert html_response(conn, 200) =~ "Log out"
  end
end
