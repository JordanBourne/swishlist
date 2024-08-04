defmodule SwishlistWeb.ShowWishlistLiveTest do
  use SwishlistWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Swishlist.AccountFixtures
  import Swishlist.WishlistFixtures
  import Swishlist.GuestFixtures
  import Swishlist.ItemFixtures

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
      guest = guest_fixture(%{wishlist: wishlist, user: user})

      {:ok, lv, _html} =
        conn
        |> live(~p"/wishlist/#{wishlist.id}/#{guest.id}")

      [first_item | _tail] = items

      lv
      |> element("#item-actions-#{first_item.id} div a", "I Bought This")
      |> render_click()

      html = render(lv)
      assert html =~ "Item marked as purchased"
    end
  end
end
