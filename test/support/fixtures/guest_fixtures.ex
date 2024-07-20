defmodule Swishlist.GuestFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Guest` context.
  """
  import Swishlist.AccountsFixtures
  import Swishlist.WishlistsFixtures

  def valid_invite_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: "some email",
      first_name: "some first_name",
      last_name: "some last_name",
      phone_number: "some phone_number",
      invited_by_id: attrs.user.id,
      wishlist_id: attrs.wishlist.id
    })
  end

  def invite_fixture(attrs \\ %{})

  def invite_fixture(%{wishlist: _wishlist, user: _user} = attrs) do
    {:ok, invite} =
      attrs
      |> valid_invite_attributes()
      |> Swishlist.Guest.create_invite()

    invite
  end

  def invite_fixture(%{user: user} = attrs) do
    wishlist = wishlist_fixture(%{user: user})

    attrs
    |> Map.put(:wishlist, wishlist)
    |> invite_fixture()
  end

  def invite_fixture(attrs) do
    user = user_fixture()

    attrs
    |> Map.put(:user, user)
    |> invite_fixture()
  end
end
