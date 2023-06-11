defmodule LiveViewStudioWeb.PresenceLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence

  @topic "users:video"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :ok = Presence.subscribe(@topic)

      {:ok, _ref} =
        Presence.track_user(
          socket.assigns.current_user,
          @topic,
          %{is_playing: false}
        )
    end

    socket =
      assign(socket,
        presences: Presence.list_users(@topic),
        is_playing: false
      )

    {:ok, socket}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)

    Presence.update_user(
      socket.assigns.current_user,
      @topic,
      %{is_playing: socket.assigns.is_playing}
    )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="presence">
      <div class="users">
        <h2>Who's Here?</h2>
        <ul>
          <li :for={{_user_id, meta} <- @presences}>
            <span class="status">
              <%= if meta.is_playing, do: "👀", else: "🙈" %>
            </span>
            <span class="username">
              <%= meta.username %>
            </span>
          </li>
        </ul>
      </div>
      <div class="video" phx-click="toggle-playing">
        <%= if @is_playing do %>
          <.icon name="hero-pause-circle-solid" />
        <% else %>
          <.icon name="hero-play-circle-solid" />
        <% end %>
      </div>
    </div>
    """
  end
end
