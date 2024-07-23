defmodule Swishlist.Repo.Migrations.CreateGifts do
  use Ecto.Migration

  def change do
    create table(:gifts) do
      add :amount, :decimal
      add :message, :string
      add :item_id, references(:items, on_delete: :nothing)
      add :to_user_id, references(:users, on_delete: :nothing)
      add :from_user_id, references(:users, on_delete: :nothing)
      add :from_guest_id, references(:guests, on_delete: :nothing)

      timestamps()
    end

    create index(:gifts, [:item_id])
    create index(:gifts, [:to_user_id])
    create index(:gifts, [:from_user_id])
    create index(:gifts, [:from_guest_id])
  end
end
