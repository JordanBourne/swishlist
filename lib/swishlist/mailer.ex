defmodule Swishlist.Mailer do
  use Swoosh.Mailer, otp_app: :swishlist
  import Swoosh.Email

  alias Swishlist.Repo
  alias Swishlist.Mailer

  def send_invite(guest) do
    guest
    |> Repo.preload(:invited_by)
    |> Repo.preload(:wishlist)
    |> invite_to_wishlist()
    |> Mailer.deliver(domain: "swishlist.io")
  end

  defp invite_to_wishlist(guest) do
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

  def send_signup_invite(guest) do
    guest
    |> Repo.preload(:invited_by)
    |> invite_to_signup()
    |> Mailer.deliver(domain: "swishlist.io")
  end

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
