defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, _volunteer} = Volunteers.toggle_status(volunteer)
    {:noreply, socket}
  end

  def handle_event("delete-volunteer", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, _volunteer} = Volunteers.delete_volunteer(volunteer)
    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = update(socket, :count, &(&1 + 1))
    {:noreply, stream_insert(socket, :volunteers, volunteer, at: 0)}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_info({:volunteer_deleted, volunteer}, socket) do
    socket = update(socket, :count, &(&1 - 1))
    {:noreply, stream_delete(socket, :volunteers, volunteer)}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component
        module={LiveViewStudioWeb.VolunteerForm}
        count={@count}
        id={:new}
      />
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
        <button phx-click={
          JS.push("toggle-status", value: %{id: @volunteer.id})
          |> JS.transition("shake", to: "##{@dom_id}", time: 500)
        }>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
      </div>
      <.link
        class="delete"
        phx-click={
          JS.push("delete-volunteer", value: %{id: @volunteer.id})
          |> JS.hide(
            to: "##{@dom_id}",
            transition: "ease duration-300 scale-0",
            time: 300
          )
        }
        phx-value-id={@volunteer.id}
        data-confirm="Are you sure?"
      >
        <.icon name="hero-trash-solid" />
      </.link>
    </div>
    """
  end
end
