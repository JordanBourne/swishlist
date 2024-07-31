defmodule SwishlistWeb.GuestLiveTest do
  use SwishlistWeb.ConnCase, async: true

  import Swoosh.TestAssertions
  import Phoenix.LiveViewTest
  import Swishlist.GuestFixtures
  import Swishlist.AccountFixtures

  @create_attrs %{
    first_name: "some first_name",
    last_name: "some last_name",
    phone_number: "111-222-3333",
    email: "test@email.com"
  }
  @update_attrs %{
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    phone_number: "111-222-4444",
    email: "test2@email.com"
  }
  @invalid_attrs %{first_name: nil, last_name: nil, phone_number: nil, email: nil}

  defp create_invite(_) do
    user = user_fixture()
    guest = guest_fixture(%{user: user})
    %{guest: guest, user: user}
  end

  describe "Index" do
    setup [:create_invite]

    test "lists all invites", %{conn: conn, guest: guest, user: user} do
      {:ok, _index_live, html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert html =~ "Listing Invites"
      assert html =~ guest.first_name
    end

    test "saves new invite", %{conn: conn, user: user} do
      {:ok, index_live, _html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert index_live |> element("a", "New Invite") |> render_click() =~
               "New Invite"

      assert_patch(index_live, ~p"/invites/new")

      assert index_live
             |> form("#guest-form", guest: @invalid_attrs)
             |> render_change() =~ "either phone number or email must be present"

      assert index_live
             |> form("#guest-form", guest: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/invites")

      html = render(index_live)
      assert html =~ "Invite created successfully"
      assert html =~ "some first_name"

      assert_email_sent(fn email ->
        assert email.to == [{"some first_name", "test@email.com"}]
        assert email.from == {"Support", "support@swishlist.io"}
        assert email.subject == "You've been invited to view Tom's wishlist"

        assert email.html_body =~ "<h1>Check out the wishlist here: http://localhost:4000/view-wishlist/"
      end)
    end

    test "updates guest in listing", %{conn: conn, guest: guest, user: user} do
      {:ok, index_live, _html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert index_live |> element("#guests-#{guest.id} a", "Edit") |> render_click() =~
               "Edit Invite"

      assert_patch(index_live, ~p"/invites/#{guest}/edit")

      assert index_live
             |> form("#guest-form", guest: @invalid_attrs)
             |> render_change() =~ "either phone number or email must be present"

      assert index_live
             |> form("#guest-form", guest: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/invites")

      html = render(index_live)
      assert html =~ "Invite updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes guest in listing", %{conn: conn, guest: guest, user: user} do
      {:ok, index_live, _html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert index_live |> element("#guests-#{guest.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#guests-#{guest.id}")
    end
  end

  describe "Show" do
    setup [:create_invite]

    test "displays guest", %{conn: conn, guest: guest, user: user} do
      {:ok, _show_live, html} = conn |> log_in_user(user) |> live(~p"/invites/#{guest}")

      assert html =~ "Show Invite"
      assert html =~ guest.first_name
    end

    test "updates guest within modal", %{conn: conn, guest: guest, user: user} do
      {:ok, show_live, _html} = conn |> log_in_user(user) |> live(~p"/invites/#{guest}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Invite"

      assert_patch(show_live, ~p"/invites/#{guest}/show/edit")

      assert show_live
             |> form("#guest-form", guest: @invalid_attrs)
             |> render_change() =~ "either phone number or email must be present"

      assert show_live
             |> form("#guest-form", guest: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/invites/#{guest}")

      html = render(show_live)
      assert html =~ "Invite updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
