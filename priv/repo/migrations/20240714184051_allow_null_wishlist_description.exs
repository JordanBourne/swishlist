defmodule Swishlist.Repo.Migrations.AllowNullWishlistDescription do
  use Ecto.Migration

  def change do
    alter table(:wishlists) do
      modify :description, :text, null: true
    end
  end
end
