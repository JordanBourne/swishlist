defmodule SwishlistWeb.InviteLive.FormComponent do
  use SwishlistWeb, :live_component

  alias Swishlist.Guest

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage invite records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="invite-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:last_name]} type="text" label="Last name" />
        <.input field={@form[:phone_number]} type="text" label="Phone number" />
        <.input field={@form[:email]} type="text" label="Email" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Invite</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{invite: invite} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Guest.change_invite(invite))
     end)}
  end

  @impl true
  def handle_event("validate", %{"invite" => invite_params}, socket) do
    changeset = Guest.change_invite(socket.assigns.invite, invite_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"invite" => invite_params}, socket) do
    save_invite(socket, socket.assigns.action, invite_params)
  end

  defp save_invite(socket, :edit, invite_params) do
    case Guest.update_invite(socket.assigns.invite, invite_params) do
      {:ok, invite} ->
        notify_parent({:saved, invite})

        {:noreply,
         socket
         |> put_flash(:info, "Invite updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_invite(socket, :new, invite_params) do
    case Guest.upsert_invite(socket.assigns.invite, invite_params) do
      {:ok, invite} ->
        notify_parent({:saved, invite})

        {:noreply,
         socket
         |> put_flash(:info, "Invite created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
