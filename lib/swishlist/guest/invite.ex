defmodule Swishlist.Guest.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :email, :string
    belongs_to :invited_by, Swishlist.Accounts.User
    belongs_to :recipient, Swishlist.Accounts.User
    belongs_to :wishlist, Swishlist.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [
      :first_name,
      :last_name,
      :phone_number,
      :email,
      :invited_by_id,
      :recipient_id,
      :wishlist_id
    ])
    |> validate_required([:invited_by_id, :wishlist_id])
    |> validate_phone_or_email()
    |> validate_phone_number()
    |> validate_email()
  end

  defp validate_phone_or_email(changeset) do
    phone_number = get_field(changeset, :phone_number)
    email = get_field(changeset, :email)

    if is_nil(phone_number) and is_nil(email) do
      add_error(changeset, :phone_number, "either phone number or email must be present")
      add_error(changeset, :email, "either phone number or email must be present")
    else
      changeset
    end
  end

  defp validate_email(changeset) do
    email = get_field(changeset, :email)

    if email do
      changeset
      |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
        message: "must have the @ sign and no spaces"
      )
      |> validate_length(:email, max: 160)
    else
      changeset
    end
  end

  defp validate_phone_number(changeset) do
    phone_number = get_field(changeset, :phone_number)

    if phone_number do
      changeset
      |> validate_format(
        :phone_number,
        ~r/^\+?(\(\d{1,3}\)|\d{1,4})[\s-]?\d{1,4}[\s-]?\d{1,4}[\s-]?\d{1,9}$/,
        message: "must be a valid phone number"
      )
      |> validate_length(:phone_number, min: 10, max: 20)
    else
      changeset
    end
  end
end
