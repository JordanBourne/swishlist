defmodule Swishlist.Repo.Migrations.AddInvitesGuests do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :first_name, :string
      add :last_name, :string
      add :phone_number, :string
      add :email, :string
      add :invited_by_id, references(:users, on_delete: :nothing), null: false
      add :recipient_id, references(:users, on_delete: :nothing)
      add :wishlist_id, references(:wishlists, on_delete: :nothing), null: false
    end
  end
end
