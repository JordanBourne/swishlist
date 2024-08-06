defmodule Swishlist.Lists.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          description: String.t() | nil,
          url: String.t() | nil,
          price: Decimal.t() | nil,
          status: String.t() | nil,
          wishlist_id: integer() | nil,
          user_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

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
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :url, :price, :status, :wishlist_id, :user_id])
    |> validate_required([:name, :url, :price, :status, :wishlist_id, :user_id])
    |> validate_status()
  end

  @spec validate_status(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_status(changeset) do
    status = get_field(changeset, :status)

    if status in @valid_status do
      changeset
    else
      add_error(changeset, :status, "Status must be one of 'NONE', 'FUNDING', 'PAID', 'COMPLETE'")
    end
  end
end
