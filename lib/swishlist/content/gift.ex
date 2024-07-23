defmodule Swishlist.Content.Gift do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gifts" do
    field :message, :string
    field :amount, :decimal
    field :item_id, :id
    field :to_user_id, :id
    field :from_user_id, :id
    field :from_guest_id, :id

    timestamps()
  end

  @doc false
  def changeset(gift, attrs) do
    gift
    |> cast(attrs, [:amount, :message])
    |> validate_required([:amount, :message])
  end
end
