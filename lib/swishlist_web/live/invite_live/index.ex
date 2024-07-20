defmodule SwishlistWeb.InviteLive.Index do
  use SwishlistWeb, :live_view

  alias Swishlist.Guest
  alias Swishlist.Guest.Invite
  alias Swishlist.Wishlists

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    {:ok, wishlist} = Wishlists.find_or_create_for_user(user)

    {
      :ok,
      socket
      |> assign(:wishlist, wishlist)
      |> assign(:user, user)
      |> stream(:invites, Guest.list_invites())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Invite")
    |> assign(:invite, Guest.get_invite!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Invite")
    |> assign(:invite, %Invite{
      invited_by_id: socket.assigns.user.id,
      wishlist_id: socket.assigns.wishlist.id
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Invites")
    |> assign(:invite, nil)
  end

  @impl true
  def handle_info({SwishlistWeb.InviteLive.FormComponent, {:saved, invite}}, socket) do
    {:noreply, stream_insert(socket, :invites, invite)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    invite = Guest.get_invite!(id)
    {:ok, _} = Guest.delete_invite(invite)

    {:noreply, stream_delete(socket, :invites, invite)}
  end
end
