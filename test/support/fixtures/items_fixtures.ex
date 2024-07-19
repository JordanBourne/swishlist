defmodule Swishlist.ItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Wishlists` context.
  """

  import Swishlist.WishlistsFixtures

  def valid_name, do: "Item Name"
  def valid_item_description, do: "Valid Item Description"
  def valid_url, do: "http://www.store.com"
  def valid_price, do: 42.42

  def valid_item_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: valid_name(),
      description: valid_description(),
      url: valid_url(),
      price: valid_price(),
      wishlist_id: attrs.wishlist.id
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
