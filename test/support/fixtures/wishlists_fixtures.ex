defmodule Swishlist.WishlistsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Wishlists` context.
  """

  import Swishlist.AccountsFixtures

  def valid_title, do: "Valid Wishlist Title"
  def valid_description, do: "All I want for Christmas is my two front teeth."
  def valid_primary, do: false

  def valid_wishlist_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      title: valid_title(),
      description: valid_description(),
      is_primary: valid_primary(),
      user_id: attrs.user.id
    })
  end

  def wishlist_fixture(attrs \\ %{})

  def wishlist_fixture(%{user: _user} = attrs) do
    {:ok, wishlist} =
      attrs
      |> valid_wishlist_attributes()
      |> Swishlist.Wishlists.create_wishlist()

    wishlist
  end

  def wishlist_fixture(attrs) do
    user = user_fixture()

    {:ok, wishlist} =
      attrs
      |> Map.put(:user, user)
      |> valid_wishlist_attributes()
      |> Swishlist.Wishlists.create_wishlist()

    wishlist
  end
end
