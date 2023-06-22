defmodule LiveViewStudioWeb.DesksLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Desks
  alias LiveViewStudio.Desks.Desk

  def mount(_params, _session, socket) do
    if connected?(socket), do: Desks.subscribe()

    socket =
      assign(socket,
        form: to_form(Desks.change_desk(%Desk{}))
      )

    {:ok, stream(socket, :desks, Desks.list_desks())}
  end

  def handle_event("validate", %{"desk" => params}, socket) do
    changeset =
      %Desk{}
      |> Desks.change_desk(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"desk" => params}, socket) do
    case Desks.create_desk(params) do
      {:ok, _desk} ->
        changeset = Desks.change_desk(%Desk{})
        {:noreply, assign_form(socket, changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_info({:desk_created, desk}, socket) do
    {:noreply, stream_insert(socket, :desks, desk, at: 0)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def render(assigns) do
    ~H"""
    <h1>What's On Your Desk?</h1>
    <div id="desks">
      <.form for={@form} phx-submit="save" phx-change="validate">
        <.input field={@form[:name]} placeholder="Name" />

        <.button phx-disable-with="Uploading...">
          Upload
        </.button>
      </.form>

      <div id="photos" phx-update="stream">
        <div :for={{dom_id, desk} <- @streams.desks} id={dom_id}>
          <div
            :for={
              {photo_location, index} <-
                Enum.with_index(desk.photo_locations)
            }
            class="photo"
          >
            <img src={photo_location} />
            <div class="name">
              <%= desk.name %> (<%= index + 1 %>)
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
