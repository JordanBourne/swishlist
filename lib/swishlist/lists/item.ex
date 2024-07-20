defmodule Swishlist.Lists.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :description, :string
    field :url, :string
    field :price, :decimal
    belongs_to :wishlist, Swishlist.List.Wishlist

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :url, :price, :wishlist_id])
    |> validate_required([:name, :url, :price])
  end
end
