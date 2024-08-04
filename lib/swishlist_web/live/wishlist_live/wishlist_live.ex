defmodule SwishlistWeb.WishlistLive do
  use SwishlistWeb, :live_view

  alias Swishlist.Accounts.Guest
  alias Swishlist.Items
  alias Swishlist.Lists.Item
  alias Swishlist.Wishlists

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    {:ok, wishlist} = Wishlists.find_or_create_for_user(user)
    items = Items.list_items(wishlist.id)

    {
      :ok,
      socket
      |> assign(:wishlist, wishlist)
      |> assign(:selected_item, 0)
      |> assign(:items, items)
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

  defp apply_action(socket, :share, _params) do
    socket
    |> assign(:invite_type, "share")
    |> assign(:modal_title, "Share Swishlist")
    |> assign(:guest, %Guest{
      invited_by_id: socket.assigns.current_user.id,
      wishlist_id: socket.assigns.wishlist.id
    })
  end

  defp apply_action(socket, :invite, _params) do
    socket
    |> assign(:invite_type, "invite")
    |> assign(:modal_title, "Invite a friend")
    |> assign(:guest, %Guest{
      invited_by_id: socket.assigns.current_user.id,
      wishlist_id: socket.assigns.wishlist.id
    })
  end

  @impl true
  def handle_event("delete_item", %{"item_id" => item_id}, socket) do
    item_id
    |> Items.get_item!()
    |> Items.delete_item()
    |> case do
      {:ok, _} -> {:noreply, assign(socket, :items, fetch_items(socket))}
      {:error, _changeset} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("select_item", %{"item_id" => item_id}, socket) do
    selected = if item_id == socket.assigns.selected_item, do: 0, else: item_id
    {:noreply, assign(socket, :selected_item, selected)}
  end

  @impl true
  def handle_info({SwishlistWeb.WishlistLive.AddItemFormComponent, {:saved, _item}}, socket) do
    {:noreply, assign(socket, :items, fetch_items(socket))}
  end

  @impl true
  def handle_info({SwishlistWeb.GuestLive.FormComponent, {:saved, _guest}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:email, _email}, socket) do
    {:noreply, socket |> put_flash(:info, "Invite sent successfully")}
  end

  defp fetch_items(socket) do
    Items.list_items(socket.assigns.wishlist.id)
  end
end
