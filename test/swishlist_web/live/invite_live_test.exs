defmodule SwishlistWeb.InviteLiveTest do
  use SwishlistWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swishlist.GuestFixtures
  import Swishlist.AccountsFixtures

  @create_attrs %{
    first_name: "some first_name",
    last_name: "some last_name",
    phone_number: "some phone_number",
    email: "some email"
  }
  @update_attrs %{
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    phone_number: "some updated phone_number",
    email: "some updated email"
  }
  @invalid_attrs %{first_name: nil, last_name: nil, phone_number: nil, email: nil}

  defp create_invite(_) do
    user = user_fixture()
    invite = invite_fixture(%{user: user})
    %{invite: invite, user: user}
  end

  describe "Index" do
    setup [:create_invite]

    test "lists all invites", %{conn: conn, invite: invite, user: user} do
      {:ok, _index_live, html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert html =~ "Listing Invites"
      assert html =~ invite.first_name
    end

    test "saves new invite", %{conn: conn, user: user} do
      {:ok, index_live, _html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert index_live |> element("a", "New Invite") |> render_click() =~
               "New Invite"

      assert_patch(index_live, ~p"/invites/new")

      assert index_live
             |> form("#invite-form", invite: @invalid_attrs)
             |> render_change() =~ "either phone number or email must be present"

      assert index_live
             |> form("#invite-form", invite: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/invites")

      html = render(index_live)
      assert html =~ "Invite created successfully"
      assert html =~ "some first_name"
    end

    test "updates invite in listing", %{conn: conn, invite: invite, user: user} do
      {:ok, index_live, _html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert index_live |> element("#invites-#{invite.id} a", "Edit") |> render_click() =~
               "Edit Invite"

      assert_patch(index_live, ~p"/invites/#{invite}/edit")

      assert index_live
             |> form("#invite-form", invite: @invalid_attrs)
             |> render_change() =~ "either phone number or email must be present"

      assert index_live
             |> form("#invite-form", invite: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/invites")

      html = render(index_live)
      assert html =~ "Invite updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes invite in listing", %{conn: conn, invite: invite, user: user} do
      {:ok, index_live, _html} = conn |> log_in_user(user) |> live(~p"/invites")

      assert index_live |> element("#invites-#{invite.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#invites-#{invite.id}")
    end
  end

  describe "Show" do
    setup [:create_invite]

    test "displays invite", %{conn: conn, invite: invite, user: user} do
      {:ok, _show_live, html} = conn |> log_in_user(user) |> live(~p"/invites/#{invite}")

      assert html =~ "Show Invite"
      assert html =~ invite.first_name
    end

    test "updates invite within modal", %{conn: conn, invite: invite, user: user} do
      {:ok, show_live, _html} = conn |> log_in_user(user) |> live(~p"/invites/#{invite}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Invite"

      assert_patch(show_live, ~p"/invites/#{invite}/show/edit")

      assert show_live
             |> form("#invite-form", invite: @invalid_attrs)
             |> render_change() =~ "either phone number or email must be present"

      assert show_live
             |> form("#invite-form", invite: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/invites/#{invite}")

      html = render(show_live)
      assert html =~ "Invite updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
