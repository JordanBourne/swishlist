defmodule Swishlist.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :description, :string
      add :url, :string
      add :price, :decimal
      add :wishlist, references(:wishlists, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:wishlist])
  end
end
