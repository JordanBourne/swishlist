defmodule Swishlist.Items do
  @moduledoc """
  Functions for interacting with items in the wishlist.

  ## Functions

  - `change_item/2`: Returns an Ecto changeset for tracking item changes.
  - `list_items/0`: Returns the list of all items.
  - `list_items/1`: Returns the list of items for a given wishlist ID.
  - `get_item!/1`: Gets a single item by its ID.
  - `create_item/1`: Creates a new item.
  - `update_item/2`: Updates an existing item.
  - `delete_item/1`: Deletes an item.
  - `mark_item_purchased_by/2`: Marks an item as purchased by a given guest.
  """

  alias Ecto.Multi
  alias Swishlist.Lists.Gift
  alias Swishlist.Lists.Item
  alias Swishlist.Repo

  import Ecto.Query

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}
  """
  @spec change_item(Item.t(), map()) :: Ecto.Changeset.t()
  def change_item(item \\ %Item{}, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]
  """
  @spec list_items() :: [Item.t()]
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Returns the list of items for the given wishlist id.

  ## Examples

      iex> list_items(wishlist_id)
      [%Item{}, ...]
  """
  @spec list_items(integer()) :: [Item.t()]
  def list_items(wishlist_id) do
    query =
      from i in Item,
        where: i.wishlist_id == ^wishlist_id

    Repo.all(query)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)
  """
  @spec get_item!(integer()) :: Item.t()
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates an item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_item(map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_item(Item.t(), map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_item(Item.t()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Marks an item as purchased by a given guest entity.

  ## Examples

      iex> mark_item_purchased_by(item)
      {:ok, %Item{}}

      iex> mark_item_purchased_by(item)
      {:error, %Ecto.Changeset{}}
  """
  @spec mark_item_purchased_by(integer(), map()) ::
          {:ok, Item.t()} | {:error, Ecto.Changeset.t() | atom()}
  def mark_item_purchased_by(item_id, %{:guest_id => guest_id}) do
    # Ecto multi
    # Create a gift record given the item and gift and the item.user_id
    # mark item as purchased
    # {:ok, gift} = Swishlist.Gifts.create_gift(gift_attrs)
    item = get_item!(item_id)

    multi =
      Multi.new()
      |> Multi.insert(
        :gift,
        Gift.changeset(%Gift{}, %{
          amount: item.price,
          message: "Purchased by guest",
          to_user_id: item.user_id,
          item_id: item.id,
          from_guest_id: guest_id
        })
      )
      |> Multi.run(:item, fn _repo, _params ->
        update_item(item, %{status: "PAID"})
      end)

    case Repo.transaction(multi) do
      {:ok, %{item: item}} ->
        {:ok, item}

      {:error, :gift, changeset, _changes} ->
        {:error, changeset}

      {:error, :item, _reason, _changes} ->
        {:error, :could_not_update_item}
    end
  end
end
