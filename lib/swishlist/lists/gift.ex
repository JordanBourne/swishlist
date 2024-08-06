defmodule Swishlist.Lists.Gift do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          message: String.t() | nil,
          amount: Decimal.t() | nil,
          item_id: integer() | nil,
          to_user_id: integer() | nil,
          from_user_id: integer() | nil,
          from_guest_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "gifts" do
    field :message, :string
    field :amount, :decimal
    belongs_to :item, Swishlist.Lists.Item
    belongs_to :to_user, Swishlist.Accounts.User
    belongs_to :from_user, Swishlist.Accounts.User
    belongs_to :from_guest, Swishlist.Accounts.Guest

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(gift, attrs) do
    gift
    |> cast(attrs, [:amount, :message, :item_id, :to_user_id, :from_user_id, :from_guest_id])
    |> validate_required([:amount, :item_id, :to_user_id])
    |> validate_from()
  end

  @spec validate_from(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_from(changeset) do
    from_user_id = get_field(changeset, :from_user_id)
    from_invite_id = get_field(changeset, :from_guest_id)

    if is_nil(from_user_id) and is_nil(from_invite_id) do
      add_error(changeset, :from_user_id, "No 'from' user specified")
      add_error(changeset, :from_guest_id, "No 'from' user specified")
    else
      changeset
    end
  end
end
