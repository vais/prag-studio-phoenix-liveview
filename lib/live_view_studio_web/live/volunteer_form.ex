defmodule LiveViewStudioWeb.VolunteerForm do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})
    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:count, assigns.count + 1)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="count">Go for it, you'll be volunteer #<%= @count %></div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
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
    </div>
    """
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
          assign(socket, :form, to_form(changeset))

        {:ok, _volunteer} ->
          changeset = Volunteers.change_volunteer(%Volunteer{})
          assign(socket, :form, to_form(changeset))
      end

    {:noreply, socket}
  end
end
