defmodule SwishlistWeb.GuestLive.Index do
  use SwishlistWeb, :live_view

  alias Swishlist.Guests
  alias Swishlist.Accounts.Guest
  alias Swishlist.Wishlists

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    {:ok, wishlist} = Wishlists.find_or_create_for_user(user)

    {
      :ok,
      socket
      |> assign(:wishlist, wishlist)
      |> assign(:user, user)
      |> stream(:guests, Guests.list_guests())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Invite")
    |> assign(:guest, Guests.get_guest!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Guest")
    |> assign(:guest, %Guest{
      invited_by_id: socket.assigns.user.id,
      wishlist_id: socket.assigns.wishlist.id
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Guest")
    |> assign(:guest, nil)
  end

  @impl true
  def handle_info({SwishlistWeb.GuestLive.FormComponent, {:saved, guest}}, socket) do
    {:noreply, stream_insert(socket, :guests, guest)}
  end

  @impl true
  def handle_info({:email, _email}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(attrs, socket) do
    IO.inspect(attrs)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    guest = Guests.get_guest!(id)
    {:ok, _} = Guests.delete_guest(guest)

    {:noreply, stream_delete(socket, :guests, guest)}
  end
end
