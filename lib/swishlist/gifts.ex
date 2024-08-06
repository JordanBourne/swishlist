defmodule Swishlist.Gifts do
  @moduledoc """
  The Gift context.

  Provides functions to manage gifts, including listing, retrieving,
  creating, updating, and deleting gifts.

  ## Functions

    * `list_gifts/0` - Returns the list of gifts.
    * `get_gift!/1` - Gets a single gift, raising `Ecto.NoResultsError` if not found.
    * `create_gift/1` - Creates a gift.
    * `update_gift/2` - Updates a gift.
    * `delete_gift/1` - Deletes a gift.
    * `change_gift/2` - Returns an `%Ecto.Changeset{}` for tracking gift changes.
  """

  import Ecto.Query, warn: false
  alias Swishlist.Repo
  alias Swishlist.Lists.Gift

  @doc """
  Returns the list of gifts.

  ## Examples

      iex> list_gifts()
      [%Gift{}, ...]
  """
  @spec list_gifts() :: [Gift.t()]
  def list_gifts do
    Repo.all(Gift)
  end

  @doc """
  Gets a single gift.

  Raises `Ecto.NoResultsError` if the Gift does not exist.

  ## Examples

      iex> get_gift!(123)
      %Gift{}

      iex> get_gift!(456)
      ** (Ecto.NoResultsError)
  """
  @spec get_gift!(integer()) :: Gift.t()
  def get_gift!(id), do: Repo.get!(Gift, id)

  @doc """
  Creates a gift.

  ## Examples

      iex> create_gift(%{field: value})
      {:ok, %Gift{}}

      iex> create_gift(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_gift(map()) :: {:ok, Gift.t()} | {:error, Ecto.Changeset.t()}
  def create_gift(attrs \\ %{}) do
    %Gift{}
    |> Gift.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a gift.

  ## Examples

      iex> update_gift(gift, %{field: new_value})
      {:ok, %Gift{}}

      iex> update_gift(gift, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_gift(Gift.t(), map()) :: {:ok, Gift.t()} | {:error, Ecto.Changeset.t()}
  def update_gift(%Gift{} = gift, attrs) do
    gift
    |> Gift.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a gift.

  ## Examples

      iex> delete_gift(gift)
      {:ok, %Gift{}}

      iex> delete_gift(gift)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_gift(Gift.t()) :: {:ok, Gift.t()} | {:error, Ecto.Changeset.t()}
  def delete_gift(%Gift{} = gift) do
    Repo.delete(gift)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gift changes.

  ## Examples

      iex> change_gift(gift)
      %Ecto.Changeset{data: %Gift{}}
  """
  @spec change_gift(Gift.t(), map()) :: Ecto.Changeset.t()
  def change_gift(%Gift{} = gift, attrs \\ %{}) do
    Gift.changeset(gift, attrs)
  end
end
