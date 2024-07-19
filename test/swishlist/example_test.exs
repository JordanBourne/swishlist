defmodule Swishlist.ExampleTest do
  use Swishlist.DataCase

  alias Swishlist.Example

  describe "name" do
    alias Swishlist.Example.Component

    import Swishlist.ExampleFixtures

    @invalid_attrs %{description: nil}

    test "list_name/0 returns all name" do
      component = component_fixture()
      assert Example.list_name() == [component]
    end

    test "get_component!/1 returns the component with given id" do
      component = component_fixture()
      assert Example.get_component!(component.id) == component
    end

    test "create_component/1 with valid data creates a component" do
      valid_attrs = %{description: "some description"}

      assert {:ok, %Component{} = component} = Example.create_component(valid_attrs)
      assert component.description == "some description"
    end

    test "create_component/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Example.create_component(@invalid_attrs)
    end

    test "update_component/2 with valid data updates the component" do
      component = component_fixture()
      update_attrs = %{description: "some updated description"}

      assert {:ok, %Component{} = component} = Example.update_component(component, update_attrs)
      assert component.description == "some updated description"
    end

    test "update_component/2 with invalid data returns error changeset" do
      component = component_fixture()
      assert {:error, %Ecto.Changeset{}} = Example.update_component(component, @invalid_attrs)
      assert component == Example.get_component!(component.id)
    end

    test "delete_component/1 deletes the component" do
      component = component_fixture()
      assert {:ok, %Component{}} = Example.delete_component(component)
      assert_raise Ecto.NoResultsError, fn -> Example.get_component!(component.id) end
    end

    test "change_component/1 returns a component changeset" do
      component = component_fixture()
      assert %Ecto.Changeset{} = Example.change_component(component)
    end
  end
end
