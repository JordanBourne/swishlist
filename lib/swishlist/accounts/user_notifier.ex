defmodule Swishlist.Accounts.UserNotifier do
  import Swoosh.Email

  alias Swishlist.Mailer

  @spec deliver(recipient :: String.t(), subject :: String.t(), body :: String.t()) ::
          {:ok, Swoosh.Email.t()} | :error
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Swishlist", "support@swishlist.io"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    else
      _ -> :error
    end
  end

  @doc """
  Sends account confirmation instructions to the user.

  ## Parameters

    - `user` - The user struct with an `email` field (must be `Swishlist.Accounts.User`).
    - `url` - The URL for account confirmation (String).

  ## Returns

    - `{:ok, Swoosh.Email.t()}` on success.
    - `:error` on failure.

  ## Examples

      iex> deliver_confirmation_instructions(%Swishlist.Accounts.User{email: "user@example.com"}, "https://example.com/confirm")
      {:ok, %Swoosh.Email{}}
  """
  @spec deliver_confirmation_instructions(Swishlist.Accounts.User.t(), String.t()) ::
          {:ok, Swoosh.Email.t()} | :error
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Sends password reset instructions to the user.

  ## Parameters

    - `user` - The user struct with an `email` field (must be `Swishlist.Accounts.User`).
    - `url` - The URL for password reset (String).

  ## Returns

    - `{:ok, Swoosh.Email.t()}` on success.
    - `:error` on failure.

  ## Examples

      iex> deliver_reset_password_instructions(%Swishlist.Accounts.User{email: "user@example.com"}, "https://example.com/reset")
      {:ok, %Swoosh.Email{}}
  """
  @spec deliver_reset_password_instructions(Swishlist.Accounts.User.t(), String.t()) ::
          {:ok, Swoosh.Email.t()} | :error
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Sends email update instructions to the user.

  ## Parameters

    - `user` - The user struct with an `email` field (must be `Swishlist.Accounts.User`).
    - `url` - The URL for updating the email (String).

  ## Returns

    - `{:ok, Swoosh.Email.t()}` on success.
    - `:error` on failure.

  ## Examples

      iex> deliver_update_email_instructions(%Swishlist.Accounts.User{email: "user@example.com"}, "https://example.com/update_email")
      {:ok, %Swoosh.Email{}}
  """
  @spec deliver_update_email_instructions(Swishlist.Accounts.User.t(), String.t()) ::
          {:ok, Swoosh.Email.t()} | :error
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
