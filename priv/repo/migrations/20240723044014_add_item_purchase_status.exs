defmodule Swishlist.Repo.Migrations.AddItemPurchaseStatus do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :status, :string, null: false, default: "NONE"
    end

    create table(:gifts) do
      add :amount, :decimal, null: false
      add :message, :string
      add :item_id, references(:items, on_delete: :nothing)
      add :to_user_id, references(:users, on_delete: :nothing)
      add :from_user_id, references(:users, on_delete: :nothing)
      add :from_invite_id, references(:invites, on_delete: :nothing)

      timestamps()
    end

    create index(:gifts, [:item_id])
    create index(:gifts, [:to_user_id])
    create index(:gifts, [:from_user_id])
    create index(:gifts, [:from_invite_id])
  end
end
