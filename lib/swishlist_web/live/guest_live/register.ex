defmodule SwishlistWeb.GuestLive.Register do
  use SwishlistWeb, :live_view

  alias Swishlist.Accounts
  alias Swishlist.Accounts.User
  alias Swishlist.Guests

  @impl true
  def mount(
        %{"guest_id" => id},
        _session,
        socket
      ) do
    guest = Guests.get_guest!(id)
    changeset = Accounts.change_user_registration(%User{
      email: guest.email,
      first_name: guest.first_name,
      last_name: guest.last_name
    })

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :register, _params) do
    socket
  end

  # @impl true
  # def mount(_params, _session, %{assigns: %{guest: guest}} = socket) do
  #   changeset = Accounts.change_user_registration(%User{
  #     email: guest.email,
  #     first_name: guest.first_name,
  #     last_name: guest.last_name
  #   })
  #
  #   socket =
  #     socket
  #     |> assign(trigger_submit: false, check_errors: false)
  #     |> assign_form(changeset)
  #
  #   {:ok, socket, temporary_assigns: [form: nil]}
  # end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
