defmodule LiveViewStudioWeb.DesksLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Desks
  alias LiveViewStudio.Desks.Desk

  def mount(_params, _session, socket) do
    if connected?(socket), do: Desks.subscribe()

    socket =
      socket
      |> assign(:form, to_form(Desks.change_desk(%Desk{})))
      |> stream(:desks, Desks.list_desks())
      |> allow_upload(:photos,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 3,
        max_file_size: 30_000_000
      )

    {:ok, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    socket = cancel_upload(socket, :photos, ref)
    {:noreply, socket}
  end

  def handle_event("validate", %{"desk" => params}, socket) do
    changeset =
      %Desk{}
      |> Desks.change_desk(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"desk" => params}, socket) do
    result = consume_uploaded_entries(socket, :photos, &upload_entry(socket, &1, &2))

    params = Map.put(params, "photo_locations", result)

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

  defp upload_entry(socket, meta, entry) do
    dest =
      Path.join([
        "priv",
        "static",
        "uploads",
        "#{entry.uuid}-#{entry.client_name}"
      ])

    dest
    |> Path.dirname()
    |> File.mkdir_p!()

    File.cp!(meta.path, dest)

    {:ok, static_path(socket, "/uploads/#{Path.basename(dest)}")}
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

        <div class="hint"></div>

        <div class="drop" phx-drop-target={@uploads.photos.ref}>
          <div>
            <img src="images/upload.svg" alt="" />
            <div>
              <label for={@uploads.photos.ref}>
                Upload a file
              </label>
              or drag and drop
              <.live_file_input upload={@uploads.photos} class="sr-only" />
            </div>
            <p>
              <%= @uploads.photos.max_entries %> photos max,
              up tp <%= trunc(@uploads.photos.max_file_size / 1_000_000) %> MB each
            </p>
          </div>
        </div>

        <.error :for={error <- upload_errors(@uploads.photos)}>
          <%= Phoenix.Naming.humanize(error) %>
        </.error>

        <div :for={entry <- @uploads.photos.entries} class="entry">
          <.live_img_preview entry={entry} />
          <div class="progress">
            <div class="value"><%= entry.progress %>%</div>
            <div class="bar">
              <span style={"width: #{entry.progress}%"}></span>
            </div>
            <.error :for={error <- upload_errors(@uploads.photos, entry)}>
              <%= Phoenix.Naming.humanize(error) %>
            </.error>
          </div>
          <a phx-click="cancel-upload" phx-value-ref={entry.ref}>&times;</a>
        </div>

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
