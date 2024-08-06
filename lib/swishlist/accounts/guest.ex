defmodule Swishlist.Accounts.Guest do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema and changeset functions for the `Guest` model.

  ## Schema

    - `first_name`: The first name of the guest.
    - `last_name`: The last name of the guest.
    - `phone_number`: The phone number of the guest.
    - `email`: The email address of the guest.
    - `invited_by`: The user who invited the guest.
    - `recipient`: The user who is the recipient.
    - `wishlist`: The wishlist associated with the guest.

  ## Functions

    - `changeset/2`: Creates and validates a changeset for the `Guest` schema.
  """

  # Type alias for Guest
  @type t :: %__MODULE__{
          id: integer() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          phone_number: String.t() | nil,
          email: String.t() | nil,
          invited_by_id: integer() | nil,
          recipient_id: integer() | nil,
          wishlist_id: integer() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "guests" do
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :email, :string
    belongs_to :invited_by, Swishlist.Accounts.User
    belongs_to :recipient, Swishlist.Accounts.User
    belongs_to :wishlist, Swishlist.Lists.Wishlist

    timestamps()
  end

  @doc """
  Creates and validates a changeset for the `Guest` schema based on the given attributes.

  ## Parameters

    - `invite` - The `%Guest{}` struct or changeset.
    - `attrs` - A map of attributes to update.

  ## Examples

      iex> changeset(%Guest{}, %{first_name: "John", email: "john@example.com"})
      %Ecto.Changeset{data: %Guest{}}

      iex> changeset(%Guest{}, %{first_name: "John", phone_number: "12345"})
      %Ecto.Changeset{data: %Guest{}}
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
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
      changeset
      |> add_error(:phone_number, "either phone number or email must be present")
      |> add_error(:email, "either phone number or email must be present")
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
