defmodule Swishlist.ExampleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swishlist.Example` context.
  """

  @doc """
  Generate a component.
  """
  def component_fixture(attrs \\ %{}) do
    {:ok, component} =
      attrs
      |> Enum.into(%{
        description: "some description"
      })
      |> Swishlist.Example.create_component()

    component
  end
end
