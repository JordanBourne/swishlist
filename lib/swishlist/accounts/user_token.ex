defmodule Swishlist.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query
  alias Swishlist.Accounts.UserToken

  @moduledoc """
  A module for managing user tokens.

  Provides functions to build and verify session and email tokens for
  various contexts such as confirming accounts, resetting passwords, and
  changing email addresses.
  """

  @type t :: %__MODULE__{
          id: integer() | nil,
          token: binary(),
          sent_to: String.t() | nil,
          context: String.t(),
          user_id: integer(),
          inserted_at: NaiveDateTime.t() | nil
        }

  @type token_query :: Ecto.Query.t()

  @hash_algorithm :sha256
  @rand_size 32

  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, Swishlist.Accounts.User

    timestamps(updated_at: false)
  end

  @doc """
  Builds a session token and its corresponding token struct.

  ## Parameters

    - `user` - The user struct (must be `Swishlist.Accounts.User`).

  ## Returns

    - `{token :: binary(), token_struct :: %UserToken{}}`

  ## Examples

      iex> build_session_token(%Swishlist.Accounts.User{id: 1})
      {<<...>> , %UserToken{token: <<...>>, context: "session", user_id: 1}}
  """
  @spec build_session_token(Swishlist.Accounts.User.t()) :: {binary(), t()}
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  @doc """
  Verifies the session token and returns the corresponding query.

  The token is valid if it matches the value in the database and it has
  not expired (after `@session_validity_in_days`).

  ## Parameters

    - `token` - The session token (binary).

  ## Returns

    - `{:ok, token_query}`

  ## Examples

      iex> verify_session_token_query(<<...>>)
      {:ok, #Ecto.Query<from ...>}
  """
  @spec verify_session_token_query(token :: binary()) :: {:ok, token_query()}
  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  @doc """
  Builds an email token and its corresponding token struct.

  The non-hashed token is sent to the user via email, while the hashed
  token is stored in the database.

  ## Parameters

    - `user` - The user struct (must be `Swishlist.Accounts.User`).
    - `context` - The context for the token (String).

  ## Returns

    - `{token :: String.t(), token_struct :: %UserToken{}}`

  ## Examples

      iex> build_email_token(%Swishlist.Accounts.User{id: 1}, "confirm")
      {"token_string", %UserToken{token: <<...>>, context: "confirm", sent_to: "user@example.com", user_id: 1}}
  """
  @spec build_email_token(Swishlist.Accounts.User.t(), String.t()) :: {String.t(), t()}
  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  @doc """
  Verifies an email token and returns the corresponding query.

  The token is valid if it matches its hashed counterpart in the
  database, the user email has not changed, and it is used within a
  certain period based on the context.

  ## Parameters

    - `token` - The email token (String).
    - `context` - The context for the token (String).

  ## Returns

    - `{:ok, token_query}` or `:error`

  ## Examples

      iex> verify_email_token_query("token_string", "confirm")
      {:ok, #Ecto.Query<from ...>}
  """
  @spec verify_email_token_query(token :: String.t(), context :: String.t()) ::
          {:ok, token_query()} | :error
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Verifies a change email token and returns the corresponding query.

  The token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after `@change_email_validity_in_days`).

  ## Parameters

    - `token` - The email token (String).
    - `context` - The context for the token (String, must start with "change:").

  ## Returns

    - `{:ok, token_query}` or `:error`

  ## Examples

      iex> verify_change_email_token_query("token_string", "change:email")
      {:ok, #Ecto.Query<from ...>}
  """
  @spec verify_change_email_token_query(token :: String.t(), context :: String.t()) ::
          {:ok, token_query()} | :error
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Returns a query to find tokens by token value and context.

  ## Parameters

    - `token` - The token value (binary).
    - `context` - The context for the token (String).

  ## Returns

    - `token_query`

  ## Examples

      iex> by_token_and_context_query(<<...>>, "session")
      #Ecto.Query<from ...>
  """
  @spec by_token_and_context_query(token :: binary(), context :: String.t()) :: token_query()
  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Returns a query to find all tokens for a user in given contexts.

  ## Parameters

    - `user` - The user struct (must be `Swishlist.Accounts.User`).
    - `contexts` - List of contexts or `:all`.

  ## Returns

    - `token_query`

  ## Examples

      iex> by_user_and_contexts_query(%Swishlist.Accounts.User{id: 1}, ["confirm", "reset_password"])
      #Ecto.Query<from ...>
  """
  @spec by_user_and_contexts_query(
          user :: Swishlist.Accounts.User.t(),
          contexts :: [String.t()] | :all
        ) ::
          token_query()
  def by_user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
