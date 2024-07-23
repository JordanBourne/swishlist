defmodule Swishlist.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Content` context.
  """

  @doc """
  Generate a gift.
  """
  def gift_fixture(attrs \\ %{}) do
    {:ok, gift} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        message: "some message"
      })
      |> Swishlist.Content.create_gift()

    gift
  end
end
