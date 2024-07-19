defmodule Swishlist.Wishlists do
  @moduledoc """
  Methods for interacting with Wishlist objects
  """

  alias Swishlist.List.Wishlist
  alias Swishlist.Repo

  @doc """
  Creates a wishlist

  ## Examples

      iex> create_wishlist(%{field: value})
      {:ok, %Wishlist{}}

      iex> create_wishlist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wishlist(attrs) do
    %Wishlist{}
    |> Wishlist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a primary wishlist for specifid user if it does not already exist 

  ## Examples

      iex> find_or_create_for_user(user)
      {:ok, %Wishlist{}}

      iex> find_or_create_for_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def find_or_create_for_user(user) do
    user
    |> Wishlist.find_user_primary_wishlist()
    |> create_if_not_exist(user)
  end

  defp create_if_not_exist(wishlist, _) when is_map(wishlist), do: {:ok, wishlist}

  defp create_if_not_exist(_, user) do
    create_wishlist(%{
      title: user.first_name <> "'s Wishlist",
      is_primary: true,
      user_id: user.id
    })
  end
end
