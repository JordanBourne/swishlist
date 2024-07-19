defmodule SwishlistWeb.UserWishlistLiveTest do
  use SwishlistWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Swishlist.AccountsFixtures
  import Swishlist.WishlistsFixtures
  import Swishlist.ItemsFixtures

  setup do
    user = user_fixture()
    %{user: user}
  end

  describe "Wishlist live view" do
    @invalid_attrs %{name: nil, url: nil, price: nil}
    @valid_attrs %{name: "some item name", url: "some url", price: "42.42", description: "some item description"}

    @invalid_update_attrs %{name: nil}
    @valid_update_attrs %{name: "updated item name"}

    test "creates a wishlist for an authenticated user on page load", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/wishlist")

      assert html =~ "#{user.first_name}&#39;s Wishlist"
    end

    test "renders existing primary wishlist if user has one", %{conn: conn, user: user} do
      wishlist_fixture(%{user: user, is_primary: true, title: "Already existing wishlist"})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/wishlist")

      assert html =~ "Already existing wishlist"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/wishlist")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert flash == %{"error" => "You must log in to access this page."}
    end

    test "can add items to the wishlist", %{conn: conn, user: user} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/wishlist")

      lv
      |> element("#add_item")
      |> render_click()

      assert_patch(lv, ~p"/wishlist/add-item")

      html = render(lv)
      assert html =~ "Add Wishlist Item"

      assert lv
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "t be blank"

      assert lv
             |> form("#item-form", item: @valid_attrs)
             |> render_submit()

      assert_patch(lv, ~p"/wishlist")

      html = render(lv)
      assert html =~ "Item created successfully"
      assert html =~ "some item name"
      assert html =~ "42.42"
    end

    test "initial render includes saved wishlist items", %{conn: conn, user: user} do
      wishlist = wishlist_fixture(%{user: user, is_primary: true})
      item = item_fixture(%{wishlist: wishlist})
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/wishlist")

      html = render(lv)
      assert html =~ item.name
      assert html =~ Decimal.to_string(item.price)
    end

    test "wishlist owner can edit item in list", %{conn: conn, user: user} do
      wishlist = wishlist_fixture(%{user: user, is_primary: true})
      item = item_fixture(%{wishlist: wishlist})
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/wishlist")

      lv
      |> element("section div a", "Edit")
      |> render_click()

      assert_patch(lv, ~p"/wishlist/edit-item/#{item.id}")

      assert lv
             |> form("#item-form", item: @invalid_update_attrs)
             |> render_change() =~ "t be blank"

      assert lv
             |> form("#item-form", item: @valid_update_attrs)
             |> render_submit()

      assert_patch(lv, ~p"/wishlist")

      html = render(lv)
      assert html =~ "Item updated successfully"
      assert html =~ "updated item name"
      assert html =~ "42.42"
    end

    test "wishlist owner can delete item in list", %{conn: conn, user: user} do
      wishlist = wishlist_fixture(%{user: user, is_primary: true})
      item_fixture(%{wishlist: wishlist})
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/wishlist")

      lv
        |> element(~s|main div:fl-contains(item.name)|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/register")
    end
  end
end
