defmodule Swishlist.GuestTest do
  use Swishlist.DataCase

  alias Swishlist.Guests
  import Swishlist.AccountFixtures
  import Swishlist.WishlistFixtures

  describe "guests" do
    alias Swishlist.Accounts.Guest

    import Swishlist.GuestFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, phone_number: nil, email: nil}

    test "list_guests/0 returns all guests" do
      guest = guest_fixture()
      assert Guests.list_guests() == [guest]
    end

    test "get_guest!/1 returns the guest with given id" do
      guest = guest_fixture()
      assert Guests.get_guest!(guest.id) == guest
    end

    test "create_guest/1 with valid data creates a guest" do
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

      assert {:ok, %Guest{} = guest} = Guests.create_guest(valid_attrs)
      assert guest.first_name == "some first_name"
      assert guest.last_name == "some last_name"
      assert guest.phone_number == "123-456-1234"
      assert guest.email == "valid@email.com"
    end

    test "create_guest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Guests.create_guest(@invalid_attrs)
    end

    test "update_guest/2 with valid data updates the guest" do
      guest = guest_fixture()

      update_attrs = %{
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        phone_number: "111-222-1234",
        email: "updated@email.com"
      }

      assert {:ok, %Guest{} = guest} = Guests.update_guest(guest, update_attrs)
      assert guest.first_name == "some updated first_name"
      assert guest.last_name == "some updated last_name"
      assert guest.phone_number == "111-222-1234"
      assert guest.email == "updated@email.com"
    end

    test "update_guest/2 with invalid data returns error changeset" do
      guest = guest_fixture()
      assert {:error, %Ecto.Changeset{}} = Guests.update_guest(guest, @invalid_attrs)
      assert guest == Guests.get_guest!(guest.id)
    end

    test "delete_guest/1 deletes the guest" do
      guest = guest_fixture()
      assert {:ok, %Guest{}} = Guests.delete_guest(guest)
      assert_raise Ecto.NoResultsError, fn -> Guests.get_guest!(guest.id) end
    end

    test "change_guest/1 returns a guest changeset" do
      guest = guest_fixture()
      assert %Ecto.Changeset{} = Guests.change_guest(guest)
    end
  end
end
