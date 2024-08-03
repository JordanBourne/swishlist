defmodule Swishlist.Lists.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_status ["NONE", "FUNDING", "PAID", "COMPLETE"]

  schema "items" do
    field :name, :string
    field :description, :string
    field :url, :string
    field :price, :decimal
    field :status, :string
    belongs_to :wishlist, Swishlist.Lists.Wishlist
    belongs_to :user, Swishlist.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :url, :price, :status, :wishlist_id, :user_id])
    |> validate_required([:name, :url, :price, :status, :wishlist_id, :user_id])
    |> validate_status()
  end

  defp validate_status(changeset) do
    status = get_field(changeset, :status)

    if status in @valid_status do
      changeset
    else
      add_error(changeset, :status, "Status must be one of 'NONE', 'FUNDING', 'PAID', 'COMPLETE'")
    end
  end
end
