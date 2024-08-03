defmodule Swishlist.GiftFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Gift` context.
  """

  import Swishlist.AccountFixtures
  import Swishlist.GuestFixtures
  import Swishlist.ItemFixtures
  import Swishlist.WishlistFixtures

  def gift_fixture(attrs \\ %{}) do
    to_user = user_fixture()
    wishlist = wishlist_fixture(%{user: to_user})
    item = item_fixture(%{wishlist: wishlist})
    from_guest = guest_fixture()

    gift_attrs =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        message: "some message",
        to_user_id: to_user.id,
        item_id: item.id,
        from_guest_id: from_guest.id
      })

    {:ok, gift} = Swishlist.Gifts.create_gift(gift_attrs)
    gift
  end
end
