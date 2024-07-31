defmodule Swishlist.GuestFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Guest` context.
  """
  import Swishlist.AccountFixtures
  import Swishlist.WishlistFixtures

  def valid_guest_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: "some@email.com",
      first_name: "some first_name",
      last_name: "some last_name",
      phone_number: "123-456-1234",
      invited_by_id: attrs.user.id,
      wishlist_id: attrs.wishlist.id
    })
  end

  def guest_fixture(attrs \\ %{})

  def guest_fixture(%{wishlist: _wishlist, user: _user} = attrs) do
    {:ok, invite} =
      attrs
      |> valid_guest_attributes()
      |> Swishlist.Guests.create_guest()

    invite
  end

  def guest_fixture(%{user: user} = attrs) do
    wishlist = wishlist_fixture(%{user: user})

    attrs
    |> Map.put(:wishlist, wishlist)
    |> guest_fixture()
  end

  def guest_fixture(attrs) do
    user = user_fixture()

    attrs
    |> Map.put(:user, user)
    |> guest_fixture()
  end
end
