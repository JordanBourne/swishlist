defmodule SwishlistWeb.GiftLive.Index do
  use SwishlistWeb, :live_view

  alias Swishlist.Content
  alias Swishlist.Content.Gift

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :gifts, Content.list_gifts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Gift")
    |> assign(:gift, Content.get_gift!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Gift")
    |> assign(:gift, %Gift{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Gifts")
    |> assign(:gift, nil)
  end

  @impl true
  def handle_info({SwishlistWeb.GiftLive.FormComponent, {:saved, gift}}, socket) do
    {:noreply, stream_insert(socket, :gifts, gift)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    gift = Content.get_gift!(id)
    {:ok, _} = Content.delete_gift(gift)

    {:noreply, stream_delete(socket, :gifts, gift)}
  end
end
