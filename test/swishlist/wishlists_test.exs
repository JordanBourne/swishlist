defmodule Swishlist.WishlistsTest do
  use Swishlist.DataCase
  alias Swishlist.Wishlists
  import Swishlist.WishlistFixtures
  import Swishlist.AccountFixtures

  describe "find_or_create_for_user/1" do
    test "creates a new primary wishlist for the user if they did not have one" do
      user = user_fixture()
      wishlist_fixture(%{title: "Existing Non-Primary Wishlist", user: user})

      {:ok, new_wishlist} = Wishlists.find_or_create_for_user(user)

      assert new_wishlist.title == user.first_name <> "'s Wishlist"
    end

    test "returns the user's primary wishlist if they had one" do
      user = user_fixture()
      wishlist_fixture(%{title: "Existing Primary Wishlist", user: user, is_primary: true})

      {:ok, new_wishlist} = Wishlists.find_or_create_for_user(user)

      assert new_wishlist.title == "Existing Primary Wishlist"
    end

    test "returns wishlist for the given id" do
      user = user_fixture()

      wishlist =
        wishlist_fixture(%{title: "Existing Primary Wishlist", user: user, is_primary: true})

      new_wishlist = Wishlists.get_wishlist(wishlist.id)

      assert new_wishlist.title == "Existing Primary Wishlist"
    end
  end
end
