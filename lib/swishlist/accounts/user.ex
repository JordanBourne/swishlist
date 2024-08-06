defmodule Swishlist.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Schema and changeset functions for the `User` model.

  ## Schema

    - `email`: The user's email address.
    - `first_name`: The user's first name.
    - `last_name`: The user's last name.
    - `password`: The user's password (virtual field).
    - `hashed_password`: The hashed password stored in the database.
    - `current_password`: The current password for validation (virtual field).
    - `confirmed_at`: The timestamp when the user was confirmed.

  ## Functions

    - `registration_changeset/3`: Creates a changeset for user registration.
    - `email_changeset/3`: Creates a changeset for changing the email.
    - `password_changeset/3`: Creates a changeset for changing the password.
    - `confirm_changeset/1`: Confirms the account by setting `confirmed_at`.
    - `valid_password?/2`: Verifies if the provided password is correct.
    - `validate_current_password/2`: Validates the current password.
  """

  # Type alias for User
  @type t :: %__MODULE__{
          id: integer() | nil,
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          password: String.t() | nil,
          hashed_password: String.t() | nil,
          current_password: String.t() | nil,
          confirmed_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :naive_datetime

    timestamps()
  end

  @doc """
  Creates a user changeset for registration.

  ## Parameters

    - `user` - The `%User{}` struct or changeset.
    - `attrs` - A map of attributes to update.
    - `opts` - Options for password hashing and email validation.

  ## Options

    * `:hash_password` - Whether to hash the password. Defaults to `true`.
    * `:validate_email` - Whether to validate email uniqueness. Defaults to `true`.

  ## Examples

      iex> registration_changeset(%User{}, %{email: "user@example.com", password: "password123"})
      %Ecto.Changeset{data: %User{}}

      iex> registration_changeset(%User{}, %{email: "user@example.com"})
      %Ecto.Changeset{data: %User{}}
  """
  @spec registration_changeset(
          t(),
          map(),
          [
            {:hash_password, boolean()} | {:validate_email, boolean()}
          ]
        ) :: Ecto.Changeset.t()
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name])
    |> validate_email(opts)
    |> validate_password(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Swishlist.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  Creates a user changeset for changing the email.

  Requires that the email field is changed; otherwise, an error is added.

  ## Parameters

    - `user` - The `%User{}` struct or changeset.
    - `attrs` - A map of attributes to update.
    - `opts` - Options for email validation.

  ## Examples

      iex> email_changeset(%User{}, %{email: "new_email@example.com"})
      %Ecto.Changeset{data: %User{}}

      iex> email_changeset(%User{}, %{})
      %Ecto.Changeset{data: %User{}}
  """
  @spec email_changeset(t(), map(), keyword()) :: Ecto.Changeset.t()
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  Creates a user changeset for changing the password.

  ## Parameters

    - `user` - The `%User{}` struct or changeset.
    - `attrs` - A map of attributes to update.
    - `opts` - Options for password validation and hashing.

  ## Options

    * `:hash_password` - Whether to hash the password. Defaults to `true`.

  ## Examples

      iex> password_changeset(%User{}, %{password: "new_password123"})
      %Ecto.Changeset{data: %User{}}
  """
  @spec password_changeset(t(), map(), keyword()) :: Ecto.Changeset.t()
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at` to the current timestamp.

  ## Examples

      iex> confirm_changeset(%User{})
      %Ecto.Changeset{data: %User{}}
  """
  @spec confirm_changeset(t() | Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password against the hashed password.

  If there is no user or the user doesn't have a password, avoids timing attacks.

  ## Parameters

    - `user` - The `%User{}` struct.
    - `password` - The password to verify.

  ## Examples

      iex> valid_password?(%User{hashed_password: "hashed_password"}, "password")
      true
  """
  @spec valid_password?(t(), <<_::8, _::_*8>>) :: boolean()
  def valid_password?(%Swishlist.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password and adds an error to the changeset if invalid.

  ## Parameters

    - `changeset` - The `%Ecto.Changeset{}` struct.
    - `password` - The current password to validate.

  ## Examples

      iex> validate_current_password(%Ecto.Changeset{data: %User{hashed_password: "hashed_password"}}, "password")
      %Ecto.Changeset{valid?: true}

      iex> validate_current_password(%Ecto.Changeset{data: %User{hashed_password: "hashed_password"}}, "wrong_password")
      %Ecto.Changeset{valid?: false}
  """
  @spec validate_current_password(Ecto.Changeset.t(), String.t()) :: Ecto.Changeset.t()
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
