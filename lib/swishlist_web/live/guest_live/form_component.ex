defmodule SwishlistWeb.GuestLive.FormComponent do
  use SwishlistWeb, :live_component

  alias Swishlist.Mailer
  alias Swishlist.Guests

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="guest-form"
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
  def update(%{guest: guest} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Guests.change_guest(guest))
     end)}
  end

  @impl true
  def handle_event("validate", %{"guest" => guest_params}, socket) do
    changeset = Guests.change_guest(socket.assigns.guest, guest_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"guest" => guest_params}, socket) do
    save_guest(socket, socket.assigns.action, guest_params)
  end

  defp save_guest(socket, :edit, guest_params) do
    case Guests.update_guest(socket.assigns.guest, guest_params) do
      {:ok, guest} ->
        notify_parent({:saved, guest})

        {:noreply,
         socket
         |> put_flash(:info, "Invite updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_guest(socket, :new, guest_params) do
    case Guests.upsert_guest(socket.assigns.guest, guest_params) do
      {:ok, guest} ->
        case socket.assigns.invite_type do
          "invite" ->
            Mailer.send_signup_invite(guest)
            notify_parent({:saved, guest})
          _ ->
            Mailer.send_share_invite(guest)
            notify_parent({:saved, guest})
        end

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
