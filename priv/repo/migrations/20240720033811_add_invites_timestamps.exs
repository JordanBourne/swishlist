defmodule Swishlist.Repo.Migrations.AddInvitesTimestamps do
  use Ecto.Migration

  def change do
    alter table(:invites) do
      timestamps()
    end
  end
end
