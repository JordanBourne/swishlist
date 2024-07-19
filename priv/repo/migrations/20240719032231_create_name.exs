defmodule Swishlist.Repo.Migrations.CreateName do
  use Ecto.Migration

  def change do
    create table(:name) do
      add :description, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:name, [:user_id])
  end
end
