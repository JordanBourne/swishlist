defmodule SwishlistWeb.ShowWishlistLive do
  use SwishlistWeb, :live_view

  alias Swishlist.Guests
  alias Swishlist.Items
  alias Swishlist.Wishlists

  @impl true
  def mount(
        %{"wishlist_id" => wishlist_id},
        _session,
        %{assigns: %{current_user: _user}} = socket
      ) do
    wishlist = Wishlists.get_wishlist(wishlist_id)
    items = Items.list_items(wishlist_id)

    {
      :ok,
      socket
      |> assign(:wishlist, wishlist)
      |> assign(:items, items)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event(
        "mark_item_purchased",
        %{"item_id" => item_id},
        %{assigns: %{:guest => guest}} = socket
      ) do
    item_id
    |> Items.get_item!()

    {:noreply,
     socket
     |> put_flash(:info, "Item marked as purchased")}
  end

  @impl true
  def handle_event(
        "mark_item_purchased",
        _params,
        socket
      ) do
    {:noreply,
     socket
     |> put_flash(:info, "Please log in to mark item purchased")}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :guest_view, %{"guest_id" => guest_id}) do
    Guests.get_guest(guest_id)
    |> case do
      nil -> socket
      guest -> socket |> assign(:guest, guest)
    end
  end
end
