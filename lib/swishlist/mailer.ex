defmodule Swishlist.Mailer do
  @moduledoc """
  Handles sending emails and text messages for Swishlist.

  ## Functions

  - `send_share_invite/1`: Sends an email and/or text invite to view a wishlist.
  - `send_signup_invite/1`: Sends an email invite to sign up and create a wishlist.
  """

  use Swoosh.Mailer, otp_app: :swishlist
  import Swoosh.Email

  alias Swishlist.Repo
  alias Swishlist.Mailer

  @doc """
  Sends an email and/or text invite to view a wishlist.

  ## Examples

      iex> send_share_invite(guest)
      :ok
  """
  @spec send_share_invite(guest :: Swishlist.Accounts.Guest.t()) :: :ok | {:error, any()}
  def send_share_invite(guest) do
    guest
    |> Repo.preload(:invited_by)
    |> Repo.preload(:wishlist)
    |> send_email_invite_to_wishlist()
    |> send_text_invite_to_wishlist()
    |> Mailer.deliver(domain: "swishlist.io")
  end

  @spec send_email_invite_to_wishlist(guest :: Swishlist.Accounts.Guest.t()) ::
          Swoosh.Email.t() | map()
  defp send_email_invite_to_wishlist(%{email: email} = guest) when is_binary(email) do
    new()
    |> to({guest.first_name, guest.email})
    |> from({"Support", "support@swishlist.io"})
    |> subject("You've been invited to view #{guest.invited_by.first_name}'s wishlist")
    |> html_body(
      "<h1>Check out the wishlist here: " <>
        System.get_env("BASE_URL") <>
        "/view-wishlist/" <> Integer.to_string(guest.wishlist_id) <> "</h1>"
    )
    |> text_body("Text Body")
  end

  @spec send_text_invite_to_wishlist(guest :: Swishlist.Accounts.Guest.t()) ::
          guest :: Swishlist.Accounts.Guest.t()
  defp send_email_invite_to_wishlist(guest) do
    guest
  end

  @spec send_text_invite_to_wishlist(guest :: Swishlist.Accounts.Guest.t()) ::
          guest :: Swishlist.Accounts.Guest.t()
  defp send_text_invite_to_wishlist(%{phone_number: _phone_number} = guest) do
    guest
  end

  @spec send_text_invite_to_wishlist(guest :: Swishlist.Accounts.Guest.t()) ::
          guest :: Swishlist.Accounts.Guest.t()
  defp send_text_invite_to_wishlist(guest) do
    guest
  end

  @doc """
  Sends an email invite to sign up and create a wishlist.

  ## Examples

      iex> send_signup_invite(guest)
      :ok
  """
  @spec send_signup_invite(guest :: Swishlist.Accounts.Guest.t()) :: :ok | {:error, any()}
  def send_signup_invite(guest) do
    guest
    |> Repo.preload(:invited_by)
    |> invite_to_signup()
    |> Mailer.deliver(domain: "swishlist.io")
  end

  @spec invite_to_signup(guest :: Swishlist.Accounts.Guest.t()) :: Swoosh.Email.t()
  defp invite_to_signup(guest) do
    new()
    |> to({guest.first_name, guest.email})
    |> from({"Support", "support@swishlist.io"})
    |> subject("#{guest.invited_by.first_name} wants you to make a wishlist")
    |> html_body(
      "<h1>Make your wishlist here: " <>
        System.get_env("BASE_URL") <>
        "/guests/register/" <> Integer.to_string(guest.wishlist_id) <> "</h1>"
    )
    |> text_body("Text Body")
  end
end
