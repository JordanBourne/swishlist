defmodule SwishlistWeb.GiftLive.FormComponent do
  use SwishlistWeb, :live_component

  alias Swishlist.Content

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage gift records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="gift-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:message]} type="text" label="Message" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Gift</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{gift: gift} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Content.change_gift(gift))
     end)}
  end

  @impl true
  def handle_event("validate", %{"gift" => gift_params}, socket) do
    changeset = Content.change_gift(socket.assigns.gift, gift_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"gift" => gift_params}, socket) do
    save_gift(socket, socket.assigns.action, gift_params)
  end

  defp save_gift(socket, :edit, gift_params) do
    case Content.update_gift(socket.assigns.gift, gift_params) do
      {:ok, gift} ->
        notify_parent({:saved, gift})

        {:noreply,
         socket
         |> put_flash(:info, "Gift updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_gift(socket, :new, gift_params) do
    case Content.create_gift(gift_params) do
      {:ok, gift} ->
        notify_parent({:saved, gift})

        {:noreply,
         socket
         |> put_flash(:info, "Gift created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
