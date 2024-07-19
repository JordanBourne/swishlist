defmodule Swishlist.Example.Component do
  use Ecto.Schema
  import Ecto.Changeset

  schema "name" do
    field :description, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(component, attrs) do
    component
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
