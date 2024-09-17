defmodule Swishlist.AccountsPaymentsTest do
  use Swishlist.DataCase, async: true
  @moduletag :external

  alias Swishlist.Accounts
  import Swishlist.AccountFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "create_individual_account/1" do
    test "full make a moov payment flow", %{user: user} do
      # Create a moov account for the user
      assert {:ok, created_account} = Accounts.create_moov_account(user)

      assert created_account["foreignID"] == Integer.to_string(user.id)
      assert created_account["profile"]["individual"]["email"] == user.email
      assert created_account["profile"]["individual"]["name"]["firstName"] == user.first_name
      assert created_account["profile"]["individual"]["name"]["lastName"] == user.last_name

      # Assert that moov account id was added to the user
      user = Repo.get(Swishlist.Accounts.User, user.id)
      assert user.moov_account_id == created_account.accountID

      # Link bank account for the user
      assert {:ok, created_bank_account} =
               Accounts.create_bank_account(user, %{
                 accountNumber: "123456789",
                 routingNumber: "987654321",
                 accountType: "checking",
                 nameOnAccount: "John Doe"
               })

      assert created_bank_account.accountNumber == "123456789"
      assert created_bank_account.routingNumber == "987654321"
      assert created_bank_account.accountType == "checking"
      assert created_bank_account.nameOnAccount == "John Doe"

      # Assert that bank account was created
      bank_account = Repo.get(Swishlist.Accounts.UserBank, created_bank_account.accountID)
      assert bank_account.user_id == user.id
    end
  end
end
