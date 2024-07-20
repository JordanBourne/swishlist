defmodule SwishlistWeb.WishlistLive.AddItemFormComponent do
  use SwishlistWeb, :live_component

  alias Swishlist.Items

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Add Wishlist Item
      </.header>

      <.simple_form
        for={@form}
        id="item-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Item Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:price]} type="number" step="0.01" label="Price" />
        <:actions>
          <.button phx-disable-with="Saving...">Save List</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Items.change_item(assigns.item))
     end)}
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    form =
      Items.change_item(socket.assigns.item, item_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.action, item_params)
  end

  defp save_item(socket, :add_item, item_params) do
    item_params
    |> Map.put("wishlist_id", socket.assigns.wishlist.id)
    |> Items.create_item()
    |> case do
      {:ok, item} ->
        notify_parent({:saved, item})

        {:noreply,
         socket
         |> put_flash(:info, "Item created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_item(socket, :edit_item, item_params) do
    case Items.update_item(socket.assigns.item, item_params) do
      {:ok, item} ->
        notify_parent({:saved, item})

        {:noreply,
         socket
         |> put_flash(:info, "Item updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
