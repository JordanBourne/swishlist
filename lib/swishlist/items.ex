defmodule Swishlist.Items do
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
  def change_item(item \\ %Item{}, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Returns the list of items for the given wishlist id

  ## Examples

      iex> list_items(wishlist_id)
      [%Item{}, ...]

  """
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
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Marks an item as purchased by given user entity

  ## Examples

      iex> mark_item_purchased_by(item)
      {:ok, %Item{}}

      iex> mark_item_purchased_by(item)
      {:error, %Ecto.Changeset{}}

  """
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
