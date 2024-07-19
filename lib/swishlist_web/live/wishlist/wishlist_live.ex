defmodule SwishlistWeb.WishlistLive do
  use SwishlistWeb, :live_view

  alias Swishlist.Wishlists
  alias Swishlist.Items
  alias Swishlist.List.Item

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    {:ok, wishlist} = Wishlists.find_or_create_for_user(user)
    items = Items.list_items(wishlist.id)

    {
      :ok,
      socket
      |> assign(:wishlist, wishlist)
      |> assign(:selected_item, 0)
      |> stream(:items, items)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :add_item, _params) do
    socket
    |> assign(:item, %Item{wishlist_id: socket.assigns.wishlist.id})
  end

  defp apply_action(socket, :edit_item, %{"item_id" => item_id}) do
    socket
    |> assign(:item, Items.get_item!(item_id))
  end

  @impl true
  def handle_event("select_item", %{"item_id" => item_id}, socket) do
    selected = if item_id == socket.assigns.selected_item, do: 0, else: item_id
    {:noreply, assign(socket, :selected_item, selected)}
  end

  @impl true
  def handle_info({SwishlistWeb.WishlistLive.AddItemFormComponent, {:saved, item}}, socket) do
    {:noreply, stream_insert(socket, :items, item)}
  end
end
