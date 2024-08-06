defmodule Swishlist.Guests do
  @moduledoc """
  The Guests context.

  Provides functions to manage guests, including listing, retrieving,
  creating, updating, and deleting guests.

  ## Functions

    * `list_guests/0` - Returns the list of guests.
    * `get_guest!/1` - Gets a single guest, raising `Ecto.NoResultsError` if not found.
    * `get_guest/1` - Gets a single guest, returning `nil` if not found.
    * `create_guest/1` - Creates a guest.
    * `update_guest/2` - Updates a guest.
    * `upsert_guest/2` - Upserts a guest.
    * `delete_guest/1` - Deletes a guest.
    * `change_guest/2` - Returns an `%Ecto.Changeset{}` for tracking guest changes.
  """
  import Ecto.Query, warn: false
  alias Swishlist.Repo
  alias Swishlist.Accounts.Guest

  @doc """
  Returns the list of guests.

  ## Examples

      iex> list_guests()
      [%Guest{}, ...]
  """
  @spec list_guests() :: [Guest.t()]
  def list_guests do
    Repo.all(Guest)
  end

  @doc """
  Gets a single guest.

  Raises `Ecto.NoResultsError` if the Guest does not exist.

  ## Examples

      iex> get_guest!(123)
      %Guest{}

      iex> get_guest!(456)
      ** (Ecto.NoResultsError)
  """
  @spec get_guest!(integer()) :: Guest.t()
  def get_guest!(id), do: Repo.get!(Guest, id)

  @doc """
  Gets a single guest.

  Returns `nil` if the guest is not found.

  ## Examples

      iex> get_guest(123)
      %Guest{}

      iex> get_guest(456)
      nil
  """
  @spec get_guest(integer()) :: Guest.t() | nil
  def get_guest(id), do: Repo.get(Guest, id)

  @doc """
  Creates a guest.

  ## Examples

      iex> create_guest(%{field: value})
      {:ok, %Guest{}}

      iex> create_guest(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_guest(map()) :: {:ok, Guest.t()} | {:error, Ecto.Changeset.t()}
  def create_guest(attrs \\ %{}) do
    %Guest{}
    |> Guest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a guest.

  ## Examples

      iex> update_guest(guest, %{field: new_value})
      {:ok, %Guest{}}

      iex> update_guest(guest, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_guest(Guest.t(), map()) :: {:ok, Guest.t()} | {:error, Ecto.Changeset.t()}
  def update_guest(%Guest{} = guest, attrs) do
    guest
    |> Guest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Upserts a guest.

  ## Examples

      iex> upsert_guest(guest, %{field: new_value})
      {:ok, %Guest{}}

      iex> upsert_guest(guest, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec upsert_guest(Guest.t(), map()) :: {:ok, Guest.t()} | {:error, Ecto.Changeset.t()}
  def upsert_guest(%Guest{} = guest, attrs) do
    guest
    |> Guest.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a guest.

  ## Examples

      iex> delete_guest(guest)
      {:ok, %Guest{}}

      iex> delete_guest(guest)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_guest(Guest.t()) :: {:ok, Guest.t()} | {:error, Ecto.Changeset.t()}
  def delete_guest(%Guest{} = guest) do
    Repo.delete(guest)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking guest changes.

  ## Examples

      iex> change_guest(guest)
      %Ecto.Changeset{data: %Guest{}}
  """
  @spec change_guest(Guest.t(), map()) :: Ecto.Changeset.t()
  def change_guest(%Guest{} = guest, attrs \\ %{}) do
    Guest.changeset(guest, attrs)
  end
end
