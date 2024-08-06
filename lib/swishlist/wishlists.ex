defmodule Swishlist.Wishlists do
  @moduledoc """
  Methods for interacting with Wishlist objects.

  ## Functions

  - `create_wishlist/1`: Creates a new wishlist with the given attributes.
  - `find_or_create_for_user/1`: Finds or creates a primary wishlist for a specified user.
  - `get_wishlist/1`: Retrieves a wishlist by its ID.
  - `create_if_not_exist/2`: Helper function to create a wishlist if it doesn't already exist.
  """

  alias Swishlist.Lists.Wishlist
  alias Swishlist.Repo

  @doc """
  Creates a wishlist.

  ## Examples

      iex> create_wishlist(%{field: value})
      {:ok, %Wishlist{}}

      iex> create_wishlist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_wishlist(map()) :: {:ok, Wishlist.t()} | {:error, Ecto.Changeset.t()}
  def create_wishlist(attrs) do
    %Wishlist{}
    |> Wishlist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a primary wishlist for specified user if it does not already exist.

  ## Examples

      iex> find_or_create_for_user(user)
      {:ok, %Wishlist{}}

      iex> find_or_create_for_user(user)
      {:error, %Ecto.Changeset{}}
  """
  @spec find_or_create_for_user(map()) :: {:ok, Wishlist.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_for_user(user) do
    user
    |> Wishlist.find_user_primary_wishlist()
    |> create_if_not_exist(user)
  end

  @doc """
  Retrieves a wishlist by its ID.

  ## Examples

      iex> get_wishlist(wishlist_id)
      %Wishlist{}
  """
  @spec get_wishlist(integer()) :: Wishlist.t() | nil
  def get_wishlist(wishlist_id) do
    Repo.get(Wishlist, wishlist_id)
  end

  @spec create_if_not_exist(Wishlist.t() | nil, map()) ::
          {:ok, Wishlist.t()} | {:error, Ecto.Changeset.t()}
  defp create_if_not_exist(wishlist, _) when is_map(wishlist), do: {:ok, wishlist}

  defp create_if_not_exist(_, user) do
    create_wishlist(%{
      title: user.first_name <> "'s Wishlist",
      is_primary: true,
      user_id: user.id
    })
  end
end
