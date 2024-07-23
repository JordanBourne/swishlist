defmodule Swishlist.ContentTest do
  use Swishlist.DataCase

  alias Swishlist.Content

  describe "gifts" do
    alias Swishlist.Content.Gift

    import Swishlist.ContentFixtures

    @invalid_attrs %{message: nil, amount: nil}

    test "list_gifts/0 returns all gifts" do
      gift = gift_fixture()
      assert Content.list_gifts() == [gift]
    end

    test "get_gift!/1 returns the gift with given id" do
      gift = gift_fixture()
      assert Content.get_gift!(gift.id) == gift
    end

    test "create_gift/1 with valid data creates a gift" do
      valid_attrs = %{message: "some message", amount: "120.5"}

      assert {:ok, %Gift{} = gift} = Content.create_gift(valid_attrs)
      assert gift.message == "some message"
      assert gift.amount == Decimal.new("120.5")
    end

    test "create_gift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_gift(@invalid_attrs)
    end

    test "update_gift/2 with valid data updates the gift" do
      gift = gift_fixture()
      update_attrs = %{message: "some updated message", amount: "456.7"}

      assert {:ok, %Gift{} = gift} = Content.update_gift(gift, update_attrs)
      assert gift.message == "some updated message"
      assert gift.amount == Decimal.new("456.7")
    end

    test "update_gift/2 with invalid data returns error changeset" do
      gift = gift_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_gift(gift, @invalid_attrs)
      assert gift == Content.get_gift!(gift.id)
    end

    test "delete_gift/1 deletes the gift" do
      gift = gift_fixture()
      assert {:ok, %Gift{}} = Content.delete_gift(gift)
      assert_raise Ecto.NoResultsError, fn -> Content.get_gift!(gift.id) end
    end

    test "change_gift/1 returns a gift changeset" do
      gift = gift_fixture()
      assert %Ecto.Changeset{} = Content.change_gift(gift)
    end
  end
end
