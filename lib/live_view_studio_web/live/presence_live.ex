defmodule LiveViewStudioWeb.PresenceLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence

  @pubsub LiveViewStudio.PubSub
  @topic "users:video"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(@pubsub, @topic)

      %{current_user: user} = socket.assigns

      {:ok, _} =
        Presence.track(self(), @topic, user.id, %{
          username: user.email |> String.split("@") |> hd(),
          is_playing: false
        })
    end

    presences = Presence.list(@topic)

    socket =
      socket
      |> assign(:is_playing, false)
      |> assign(:presences, simple_presence_map(presences))

    {:ok, socket}
  end

  defp simple_presence_map(presences) do
    Enum.into(
      presences,
      %{},
      fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end
    )
  end

  def render(assigns) do
    ~H"""
    <div id="presence">
      <div class="users">
        <h2>Who's Here?</h2>
        <ul>
          <li :for={{user_id, meta} <- @presences}>
            <span class="status">
              <%= if meta.is_playing, do: "👀", else: "🙈" %>
            </span>
            <span class="username">
              <%= meta.username %> (<%= user_id %>)
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

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    socket =
      socket
      |> remove_presences(diff)
      |> add_presences(diff)

    {:noreply, socket}
  end

  defp remove_presences(socket, diff) do
    presences =
      Map.reject(socket.assigns.presences, fn {user_id, _meta} ->
        Map.has_key?(diff.leaves, user_id)
      end)

    assign(socket, :presences, presences)
  end

  defp add_presences(socket, diff) do
    presences =
      Map.merge(
        socket.assigns.presences,
        simple_presence_map(diff.joins)
      )

    assign(socket, :presences, presences)
  end

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)

    Presence.update(
      self(),
      @topic,
      socket.assigns.current_user.id,
      &%{&1 | is_playing: socket.assigns.is_playing}
    )

    {:noreply, socket}
  end
end
