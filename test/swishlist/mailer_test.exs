defmodule Swishlist.MailerTest do
  use Swishlist.DataCase, async: true
  alias Swishlist.Repo
  alias Swishlist.Mailer

  import Swoosh.TestAssertions
  import Swishlist.GuestFixtures
  import Swishlist.AccountsFixtures

  describe "mailer" do
    test "send email to guest" do
      user = user_fixture()
      guest = invite_fixture(%{user: user}) |> Repo.preload(:invited_by)
      Mailer.send_invite(guest)

      assert_email_sent(fn email -> 
        assert email.to == [{guest.first_name, guest.email}]
        assert email.from == {"Support", "support@swishlist.io"}
        assert email.subject == "You've been invited to view #{guest.invited_by.first_name}'s wishlist"
        assert email.html_body == "<h1>Hello World</h1>"
        assert email.text_body == "Text Body"
      end)
    end
  end
end
