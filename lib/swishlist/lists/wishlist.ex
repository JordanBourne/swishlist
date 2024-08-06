defmodule Swishlist.Lists.Wishlist do
  @moduledoc """
  Wishlist ORM
  """

  use Ecto.Schema
  alias Swishlist.Repo
  import Ecto.Changeset

  # Type alias for Wishlist
  @type t :: %__MODULE__{
          id: integer() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          is_primary: boolean() | nil,
          user_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "wishlists" do
    field :description, :string
    field :title, :string
    field :is_primary, :boolean, default: false
    belongs_to :user, Swishlist.Accounts.User

    timestamps()
  end

  @doc """
  Creates a changeset based on the `Wishlist` schema and the given attributes.

  ## Parameters

    - `wishlist` - The `%Wishlist{}` struct or changeset.
    - `attrs` - A map of attributes to update.

  ## Examples

      iex> changeset(%Wishlist{}, %{title: "New Wishlist"})
      %Ecto.Changeset{data: %Wishlist{}}

      iex> changeset(%Wishlist{}, %{title: nil})
      %Ecto.Changeset{data: %Wishlist{}}
  """
  @spec changeset(wishlist :: t(), attrs :: map()) :: Ecto.Changeset.t()
  def changeset(wishlist, attrs) do
    wishlist
    |> cast(attrs, [:title, :description, :is_primary, :user_id])
    |> validate_required([:title, :user_id])
  end

  @doc """
  Finds the primary wishlist for the given user.

  ## Parameters

    - `user` - The user for whom to find the primary wishlist.

  ## Examples

      iex> find_user_primary_wishlist(%User{id: 1})
      %Wishlist{}

      iex> find_user_primary_wishlist(%User{id: 2})
      nil
  """
  @spec find_user_primary_wishlist(user :: Swishlist.Accounts.User.t()) :: t() | nil
  def find_user_primary_wishlist(user) do
    Repo.get_by(Swishlist.Lists.Wishlist, user_id: user.id, is_primary: true)
  end
end
