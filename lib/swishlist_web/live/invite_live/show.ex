defmodule SwishlistWeb.InviteLive.Show do
  use SwishlistWeb, :live_view

  alias Swishlist.Guest

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:invite, Guest.get_invite!(id))}
  end

  defp page_title(:show), do: "Show Invite"
  defp page_title(:edit), do: "Edit Invite"
end
