defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      socket
      |> stream(:volunteers, Volunteers.list_volunteers())
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{}, volunteer_params)

    form =
      changeset
      |> Map.put(:action, :validate)
      |> to_form()

    socket =
      socket
      |> assign(:form, form)

    {:noreply, socket}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    socket =
      case Volunteers.create_volunteer(volunteer_params) do
        {:error, changeset} ->
          form = to_form(changeset)

          socket
          |> assign(:form, form)

        {:ok, volunteer} ->
          changeset = Volunteers.change_volunteer(%Volunteer{})

          socket
          |> stream_insert(:volunteers, volunteer, at: 0)
          |> assign(:form, to_form(changeset))
      end

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, volunteer} = Volunteers.toggle_status(volunteer)
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_event("delete-volunteer", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, volunteer} = Volunteers.delete_volunteer(volunteer)
    socket = stream_delete(socket, :volunteers, volunteer)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input
          field={@form[:name]}
          placeholder="Name"
          autocomplete="off"
          phx-debounce="blur"
        />
        <.input
          field={@form[:phone]}
          placeholder="Phone"
          type="tel"
          autocomplete="off"
          phx-debounce="blur"
        />
        <.button phx-disable-with="Saving...">
          Check in
        </.button>
      </.form>
      <div id="volunteers" phx-update="stream">
        <div
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          id={volunteer_id}
          class={"volunteer #{if volunteer.checked_out, do: "out"}"}
        >
          <div class="name">
            <%= volunteer.name %>
          </div>
          <div class="phone">
            <%= volunteer.phone %>
          </div>
          <div class="status">
            <button phx-click="toggle-status" phx-value-id={volunteer.id}>
              <%= if volunteer.checked_out,
                do: "Check In",
                else: "Check Out" %>
            </button>
          </div>
          <.link
            class="delete"
            phx-click="delete-volunteer"
            phx-value-id={volunteer.id}
            data-confirm="Are you sure?"
          >
            <.icon name="hero-trash-solid" />
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
