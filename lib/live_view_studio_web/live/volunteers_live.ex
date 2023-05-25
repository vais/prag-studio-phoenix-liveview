defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        volunteers: Volunteers.list_volunteers(),
        form: to_form(Volunteers.change_volunteer(%Volunteer{}))
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    form =
      Volunteers.change_volunteer(%Volunteer{}, volunteer_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
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
          |> update(:volunteers, &[volunteer | &1])
          |> assign(:form, to_form(changeset))
      end

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
      <div
        :for={volunteer <- @volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
      >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
      </div>
    </div>
    """
  end
end
