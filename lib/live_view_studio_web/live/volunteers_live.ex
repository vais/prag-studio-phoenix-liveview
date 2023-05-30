defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :volunteers, Volunteers.list_volunteers())}
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

  def handle_info({:volunteer_created, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer, at: 0)}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component module={LiveViewStudioWeb.VolunteerForm} id={:new} />
      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{dom_id, volunteer} <- @streams.volunteers}
          dom_id={dom_id}
          volunteer={volunteer}
        />
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div
      id={@dom_id}
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
    >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
        <button phx-click="toggle-status" phx-value-id={@volunteer.id}>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
      </div>
      <.link
        class="delete"
        phx-click="delete-volunteer"
        phx-value-id={@volunteer.id}
        data-confirm="Are you sure?"
      >
        <.icon name="hero-trash-solid" />
      </.link>
    </div>
    """
  end
end
