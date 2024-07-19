defmodule Swishlist.Repo.Migrations.AddWishlistIdToItem do
  use Ecto.Migration

  def change do
    alter table(:items) do
      remove :wishlist
      add :wishlist_id, references(:wishlists, on_delete: :nothing)
    end
  end
end
