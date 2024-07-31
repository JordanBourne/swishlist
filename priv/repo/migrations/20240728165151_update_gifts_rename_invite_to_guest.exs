defmodule Swishlist.Repo.Migrations.UpdateGiftsRenameInviteToGuest do
  use Ecto.Migration

  def change do
    rename table(:gifts), :from_invite_id, to: :from_guest_id

    alter table(:gifts) do
      modify :from_guest_id, references(:guests, on_delete: :nothing)
    end

    drop index(:gifts, [:from_invite_id])
    create index(:gifts, [:from_guest_id])
  end
end
