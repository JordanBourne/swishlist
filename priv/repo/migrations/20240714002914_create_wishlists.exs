defmodule Swishlist.Repo.Migrations.CreateWishlists do
  use Ecto.Migration

  def change do
    create table(:wishlists) do
      add :title, :string
      add :description, :string
      add :is_primary, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:wishlists, [:user_id])
  end
end
