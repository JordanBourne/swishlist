defmodule SwishlistWeb.ComponentLive.Index do
  use SwishlistWeb, :live_view

  alias Swishlist.Example
  alias Swishlist.Example.Component

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :name, Example.list_name())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Component")
    |> assign(:component, Example.get_component!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Component")
    |> assign(:component, %Component{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Name")
    |> assign(:component, nil)
  end

  @impl true
  def handle_info({SwishlistWeb.ComponentLive.FormComponent, {:saved, component}}, socket) do
    {:noreply, stream_insert(socket, :name, component)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    component = Example.get_component!(id)
    {:ok, _} = Example.delete_component(component)

    {:noreply, stream_delete(socket, :name, component)}
  end
end
