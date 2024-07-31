defmodule Swishlist.ItemsTest do
  use Swishlist.DataCase
  alias Swishlist.Items
  alias Swishlist.Lists.Item

  import Swishlist.ItemFixtures
  import Swishlist.WishlistFixtures

  describe "items" do
    @invalid_attrs %{name: nil, url: nil, price: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Items.list_items() == [item]
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{name: "some name", url: "some url", price: "120.5", purchased: true}

      assert {:ok, %Item{} = item} = Items.create_item(valid_attrs)
      assert item.name == "some name"
      assert item.url == "some url"
      assert item.price == Decimal.new("120.5")
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Items.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()

      update_attrs = %{
        name: "some updated name",
        url: "some updated url",
        price: "456.7",
        purchased: false
      }

      assert {:ok, %Item{} = item} = Items.update_item(item, update_attrs)
      assert item.name == "some updated name"
      assert item.url == "some updated url"
      assert item.price == Decimal.new("456.7")
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Items.update_item(item, @invalid_attrs)
      assert item == Items.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Items.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Items.change_item(item)
    end

    test "list_items/1 returns a list of items for given wishlist" do
      wishlist = wishlist_fixture()
      first_item = item_fixture(%{wishlist: wishlist})
      second_item = item_fixture(%{wishlist: wishlist})

      item_fixture()

      assert [first_item, second_item] == Items.list_items(wishlist.id)
    end
  end
end
