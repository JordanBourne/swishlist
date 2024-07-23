defmodule SwishlistWeb.ShowWishlistLiveTest do
  use SwishlistWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Swishlist.AccountsFixtures
  import Swishlist.WishlistsFixtures
  import Swishlist.GuestFixtures
  import Swishlist.ItemsFixtures

  setup do
    user = user_fixture()
    wishlist = wishlist_fixture()

    items = [
      item_fixture(%{user: user, wishlist: wishlist, name: "Item 1"}),
      item_fixture(%{user: user, wishlist: wishlist, name: "Item 2"}),
      item_fixture(%{user: user, wishlist: wishlist, name: "Item 3"}),
      item_fixture(%{user: user, wishlist: wishlist, name: "Item 4"})
    ]

    %{user: user, wishlist: wishlist, items: items}
  end

  describe "Wishlist live view" do
    test "unauthenticated person can view a given wishlist", %{
      conn: conn,
      wishlist: wishlist,
      items: items
    } do
      {:ok, _lv, html} =
        conn
        |> live(~p"/wishlist/#{wishlist.id}")

      assert html =~ wishlist.title

      for item <- items do
        assert html =~ item.name
      end
    end

    test "guest can mark a gift as purchased", %{
      conn: conn,
      wishlist: wishlist,
      user: user,
      items: items
    } do
      invite = invite_fixture(%{wishlist: wishlist, user: user})

      {:ok, lv, _html} =
        conn
        |> live(~p"/wishlist/#{wishlist.id}/#{invite.id}")

      [first_item | _tail] = items

      lv
      |> element("#item-actions-#{first_item.id} div a", "I Bought This")
      |> render_click()

      html = render(lv)
      assert html =~ "Item marked as purchased"

      # assert that the item has been marked as purchased
      # tracking purchase status on item table
      # NONE | FUNDING | PAID | COMPLETE

      # Item Contributions table - item_id, user_id, amountq
    end
  end
end
