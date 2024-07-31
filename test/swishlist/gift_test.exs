defmodule Swishlist.GiftTest do
  use Swishlist.DataCase
  alias Swishlist.Gifts

  describe "gifts" do
    alias Swishlist.Lists.Gift

    import Swishlist.GiftFixtures

    @invalid_attrs %{message: nil, amount: nil}

    test "list_gifts/0 returns all gifts" do
      gift = gift_fixture()
      assert Gifts.list_gifts() == [gift]
    end

    test "get_gift!/1 returns the gift with given id" do
      gift = gift_fixture()
      assert Gifts.get_gift!(gift.id) == gift
    end

    test "create_gift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gifts.create_gift(@invalid_attrs)
    end

    test "update_gift/2 with valid data updates the gift" do
      gift = gift_fixture()
      update_attrs = %{message: "some updated message", amount: "456.7"}

      assert {:ok, %Gift{} = gift} = Gifts.update_gift(gift, update_attrs)
      assert gift.message == "some updated message"
      assert gift.amount == Decimal.new("456.7")
    end

    test "update_gift/2 with invalid data returns error changeset" do
      gift = gift_fixture()
      assert {:error, %Ecto.Changeset{}} = Gifts.update_gift(gift, @invalid_attrs)
      assert gift == Gifts.get_gift!(gift.id)
    end

    test "delete_gift/1 deletes the gift" do
      gift = gift_fixture()
      assert {:ok, %Gift{}} = Gifts.delete_gift(gift)
      assert_raise Ecto.NoResultsError, fn -> Gifts.get_gift!(gift.id) end
    end

    test "change_gift/1 returns a gift changeset" do
      gift = gift_fixture()
      assert %Ecto.Changeset{} = Gifts.change_gift(gift)
    end
  end
end
