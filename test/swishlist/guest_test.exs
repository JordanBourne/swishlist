defmodule Swishlist.GuestTest do
  use Swishlist.DataCase

  alias Swishlist.Guest
  import Swishlist.AccountsFixtures
  import Swishlist.WishlistsFixtures

  describe "invites" do
    alias Swishlist.Guest.Invite

    import Swishlist.GuestFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, phone_number: nil, email: nil}

    test "list_invites/0 returns all invites" do
      invite = invite_fixture()
      assert Guest.list_invites() == [invite]
    end

    test "get_invite!/1 returns the invite with given id" do
      invite = invite_fixture()
      assert Guest.get_invite!(invite.id) == invite
    end

    test "create_invite/1 with valid data creates a invite" do
      user = user_fixture()
      wishlist = wishlist_fixture(%{user: user})

      valid_attrs = %{
        first_name: "some first_name",
        last_name: "some last_name",
        phone_number: "123-456-1234",
        email: "valid@email.com",
        wishlist_id: wishlist.id,
        invited_by_id: user.id
      }

      assert {:ok, %Invite{} = invite} = Guest.create_invite(valid_attrs)
      assert invite.first_name == "some first_name"
      assert invite.last_name == "some last_name"
      assert invite.phone_number == "123-456-1234"
      assert invite.email == "valid@email.com"
    end

    test "create_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Guest.create_invite(@invalid_attrs)
    end

    test "update_invite/2 with valid data updates the invite" do
      invite = invite_fixture()

      update_attrs = %{
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        phone_number: "111-222-1234",
        email: "updated@email.com"
      }

      assert {:ok, %Invite{} = invite} = Guest.update_invite(invite, update_attrs)
      assert invite.first_name == "some updated first_name"
      assert invite.last_name == "some updated last_name"
      assert invite.phone_number == "111-222-1234"
      assert invite.email == "updated@email.com"
    end

    test "update_invite/2 with invalid data returns error changeset" do
      invite = invite_fixture()
      assert {:error, %Ecto.Changeset{}} = Guest.update_invite(invite, @invalid_attrs)
      assert invite == Guest.get_invite!(invite.id)
    end

    test "delete_invite/1 deletes the invite" do
      invite = invite_fixture()
      assert {:ok, %Invite{}} = Guest.delete_invite(invite)
      assert_raise Ecto.NoResultsError, fn -> Guest.get_invite!(invite.id) end
    end

    test "change_invite/1 returns a invite changeset" do
      invite = invite_fixture()
      assert %Ecto.Changeset{} = Guest.change_invite(invite)
    end
  end
end
