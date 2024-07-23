defmodule SwishlistWeb.GiftLiveTest do
  use SwishlistWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swishlist.ContentFixtures

  @create_attrs %{message: "some message", amount: "120.5"}
  @update_attrs %{message: "some updated message", amount: "456.7"}
  @invalid_attrs %{message: nil, amount: nil}

  defp create_gift(_) do
    gift = gift_fixture()
    %{gift: gift}
  end

  describe "Index" do
    setup [:create_gift]

    test "lists all gifts", %{conn: conn, gift: gift} do
      {:ok, _index_live, html} = live(conn, ~p"/gifts")

      assert html =~ "Listing Gifts"
      assert html =~ gift.message
    end

    test "saves new gift", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/gifts")

      assert index_live |> element("a", "New Gift") |> render_click() =~
               "New Gift"

      assert_patch(index_live, ~p"/gifts/new")

      assert index_live
             |> form("#gift-form", gift: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#gift-form", gift: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/gifts")

      html = render(index_live)
      assert html =~ "Gift created successfully"
      assert html =~ "some message"
    end

    test "updates gift in listing", %{conn: conn, gift: gift} do
      {:ok, index_live, _html} = live(conn, ~p"/gifts")

      assert index_live |> element("#gifts-#{gift.id} a", "Edit") |> render_click() =~
               "Edit Gift"

      assert_patch(index_live, ~p"/gifts/#{gift}/edit")

      assert index_live
             |> form("#gift-form", gift: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#gift-form", gift: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/gifts")

      html = render(index_live)
      assert html =~ "Gift updated successfully"
      assert html =~ "some updated message"
    end

    test "deletes gift in listing", %{conn: conn, gift: gift} do
      {:ok, index_live, _html} = live(conn, ~p"/gifts")

      assert index_live |> element("#gifts-#{gift.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#gifts-#{gift.id}")
    end
  end

  describe "Show" do
    setup [:create_gift]

    test "displays gift", %{conn: conn, gift: gift} do
      {:ok, _show_live, html} = live(conn, ~p"/gifts/#{gift}")

      assert html =~ "Show Gift"
      assert html =~ gift.message
    end

    test "updates gift within modal", %{conn: conn, gift: gift} do
      {:ok, show_live, _html} = live(conn, ~p"/gifts/#{gift}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Gift"

      assert_patch(show_live, ~p"/gifts/#{gift}/show/edit")

      assert show_live
             |> form("#gift-form", gift: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#gift-form", gift: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/gifts/#{gift}")

      html = render(show_live)
      assert html =~ "Gift updated successfully"
      assert html =~ "some updated message"
    end
  end
end
