defmodule LiveViewStudioWeb.ServerForm do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})
    socket = assign(socket, form: to_form(changeset))
    {:ok, socket}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:ok, server} ->
        send(self(), {__MODULE__, :server_created, server})
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    form =
      Servers.change_server(%Server{}, server_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
        autocomplete="off"
      >
        <div class="field">
          <.input field={@form[:name]} label="Name" phx-debounce="2000" />
        </div>
        <div class="field">
          <.input
            field={@form[:framework]}
            label="Framework"
            phx-debounce="2000"
          />
        </div>
        <div class="field">
          <.input
            field={@form[:size]}
            label="Size (MB)"
            type="number"
            phx-debounce="2000"
          />
        </div>
        <div class="field">
          <.button phx-disable-with="Saving...">Save</.button>
          <.link patch={~p"/servers"} class="cancel">
            Cancel
          </.link>
        </div>
      </.form>
    </div>
    """
  end
end
