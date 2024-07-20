defmodule Swishlist.List.Wishlist do
  @moduledoc """
  Wishlist ORM
  """
  use Ecto.Schema
  alias Swishlist.Repo

  import Ecto.Changeset

  schema "wishlists" do
    field :description, :string
    field :title, :string
    field :is_primary, :boolean, default: false
    belongs_to :user, Swishlist.Account.User

    timestamps()
  end

  @doc false
  def changeset(wishlist, attrs) do
    wishlist
    |> cast(attrs, [:title, :description, :is_primary, :user_id])
    |> validate_required([:title, :user_id])
  end

  def find_user_primary_wishlist(user) do
    Repo.get_by(Swishlist.List.Wishlist, user_id: user.id, is_primary: true)
  end
end
