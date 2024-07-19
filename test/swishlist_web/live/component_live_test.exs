defmodule SwishlistWeb.ComponentLiveTest do
  use SwishlistWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swishlist.ExampleFixtures

  @create_attrs %{description: "some description"}
  @update_attrs %{description: "some updated description"}
  @invalid_attrs %{description: nil}

  defp create_component(_) do
    component = component_fixture()
    %{component: component}
  end

  describe "Index" do
    setup [:create_component]

    test "lists all name", %{conn: conn, component: component} do
      {:ok, _index_live, html} = live(conn, ~p"/name")

      assert html =~ "Listing Name"
      assert html =~ component.description
    end

    test "saves new component", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/name")

      assert index_live |> element("a", "New Component") |> render_click() =~
               "New Component"

      assert_patch(index_live, ~p"/name/new")

      assert index_live
             |> form("#component-form", component: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#component-form", component: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/name")

      html = render(index_live)
      assert html =~ "Component created successfully"
      assert html =~ "some description"
    end

    test "updates component in listing", %{conn: conn, component: component} do
      {:ok, index_live, _html} = live(conn, ~p"/name")

      assert index_live |> element("#name-#{component.id} a", "Edit") |> render_click() =~
               "Edit Component"

      assert_patch(index_live, ~p"/name/#{component}/edit")

      assert index_live
             |> form("#component-form", component: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#component-form", component: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/name")

      html = render(index_live)
      assert html =~ "Component updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes component in listing", %{conn: conn, component: component} do
      {:ok, index_live, _html} = live(conn, ~p"/name")

      assert index_live |> element("#name-#{component.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#name-#{component.id}")
    end
  end

  describe "Show" do
    setup [:create_component]

    test "displays component", %{conn: conn, component: component} do
      {:ok, _show_live, html} = live(conn, ~p"/name/#{component}")

      assert html =~ "Show Component"
      assert html =~ component.description
    end

    test "updates component within modal", %{conn: conn, component: component} do
      {:ok, show_live, _html} = live(conn, ~p"/name/#{component}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Component"

      assert_patch(show_live, ~p"/name/#{component}/show/edit")

      assert show_live
             |> form("#component-form", component: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#component-form", component: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/name/#{component}")

      html = render(show_live)
      assert html =~ "Component updated successfully"
      assert html =~ "some updated description"
    end
  end
end
