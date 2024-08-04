defmodule Swishlist.MailerTest do
  use Swishlist.DataCase, async: true
  alias Swishlist.Repo
  alias Swishlist.Mailer

  import Swoosh.TestAssertions
  import Swishlist.GuestFixtures
  import Swishlist.AccountFixtures

  describe "mailer" do
    test "send invite to wishlist email to guest" do
      user = user_fixture()
      guest = guest_fixture(%{user: user}) |> Repo.preload(:invited_by)
      Mailer.send_share_invite(guest)

      assert_email_sent(fn email ->
        assert email.to == [{guest.first_name, guest.email}]
        assert email.from == {"Support", "support@swishlist.io"}

        assert email.subject ==
                 "You've been invited to view #{guest.invited_by.first_name}'s wishlist"

        assert email.html_body =~
                 "<h1>Check out the wishlist here: http://localhost:4000/view-wishlist/" <>
                   Integer.to_string(guest.wishlist_id) <> "</h1>"

        assert email.text_body == "Text Body"
      end)
    end

    test "send signup email to guest" do
      user = user_fixture()
      guest = guest_fixture(%{user: user}) |> Repo.preload(:invited_by)
      Mailer.send_signup_invite(guest)

      assert_email_sent(fn email ->
        assert email.to == [{guest.first_name, guest.email}]
        assert email.from == {"Support", "support@swishlist.io"}

        assert email.subject ==
                 "#{guest.invited_by.first_name} wants you to make a wishlist"

        assert email.html_body =~
                 "<h1>Make your wishlist here: http://localhost:4000/guests/register/" <>
                   Integer.to_string(guest.wishlist_id) <> "</h1>"

        assert email.text_body == "Text Body"
      end)
    end
  end
end
