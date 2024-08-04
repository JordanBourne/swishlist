defmodule SwishlistWeb.GuestLive.RegisterTest do
  use SwishlistWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Swishlist.AccountFixtures
  import Swishlist.GuestFixtures

  defp create_guest(_) do
    user = user_fixture()
    guest = guest_fixture(%{user: user})
    %{guest: guest}
  end

  describe "Guest Registration page" do
    setup [:create_guest]

    test "renders registration page as guest", %{conn: conn, guest: guest} do
      {:ok, _lv, html} = live(conn, ~p"/guest/register/#{guest.id}")

      assert html =~ "Register"
      assert html =~ "Log in"
      assert html =~ guest.first_name
      assert html =~ guest.last_name
      assert html =~ guest.email
    end

    test "redirects if already logged in", %{conn: conn, guest: guest} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/guest/register/#{guest.id}")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn, guest: guest} do
      {:ok, lv, _html} = live(conn, ~p"/guest/register/#{guest.id}")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces", "password" => "too short"})

      assert result =~ "Register"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
    end
  end

  describe "register user" do
    setup [:create_guest]

    test "creates account and logs the user in", %{conn: conn, guest: guest} do
      {:ok, lv, _html} = live(conn, ~p"/guest/register/#{guest.id}")

      email = unique_user_email()
      form = form(lv, "#registration_form", user: valid_user_attributes(email: email))
      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ "Settings"
      assert response =~ "Log out"
    end

    test "renders errors for duplicated email", %{conn: conn, guest: guest} do
      {:ok, lv, _html} = live(conn, ~p"/guest/register/#{guest.id}")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    setup [:create_guest]

    test "redirects to login page when the Log in button is clicked", %{conn: conn, guest: guest} do
      {:ok, lv, _html} = live(conn, ~p"/guest/register/#{guest.id}")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
