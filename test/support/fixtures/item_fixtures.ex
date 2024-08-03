defmodule Swishlist.ItemFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Wishlists` context.
  """

  import Swishlist.WishlistFixtures

  def valid_name, do: "Item Name"
  def valid_item_description, do: "Valid Item Description"
  def valid_url, do: "http://www.store.com"
  def valid_price, do: 42.42
  def valid_status, do: "NONE"

  def valid_item_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: valid_name(),
      description: valid_description(),
      url: valid_url(),
      price: valid_price(),
      status: valid_status(),
      wishlist_id: attrs.wishlist.id,
      user_id: attrs.wishlist.user_id
    })
  end

  def item_fixture(attrs \\ %{})

  def item_fixture(%{wishlist: _wishlist} = attrs) do
    {:ok, wishlist} =
      attrs
      |> valid_item_attributes()
      |> Swishlist.Items.create_item()

    wishlist
  end

  def item_fixture(attrs) do
    wishlist = wishlist_fixture()

    {:ok, item} =
      attrs
      |> Map.put(:wishlist, wishlist)
      |> valid_item_attributes()
      |> Swishlist.Items.create_item()

    item
  end
end
