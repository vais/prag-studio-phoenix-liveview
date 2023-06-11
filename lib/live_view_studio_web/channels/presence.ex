defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  @pubsub LiveViewStudio.PubSub

  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: @pubsub

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(@pubsub, topic)
  end

  def track_user(user, topic, meta) do
    meta = Map.merge(%{username: username(user)}, meta)
    track(self(), topic, user.id, meta)
  end

  defp username(user), do: user.email |> String.split("@") |> hd()

  def update_user(user, topic, meta) do
    meta = &Map.merge(&1, meta)
    update(self(), topic, user.id, meta)
  end

  def list_users(topic) do
    list(topic) |> simple_presence_map()
  end

  defp simple_presence_map(presences) do
    Enum.into(
      presences,
      %{},
      fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end
    )
  end

  def handle_diff(socket, diff) do
    socket
    |> remove_presences(diff)
    |> add_presences(diff)
  end

  defp remove_presences(socket, diff) do
    presences =
      Map.reject(socket.assigns.presences, fn {user_id, _meta} ->
        Map.has_key?(diff.leaves, user_id)
      end)

    Phoenix.Component.assign(socket, :presences, presences)
  end

  defp add_presences(socket, diff) do
    presences =
      Map.merge(
        socket.assigns.presences,
        simple_presence_map(diff.joins)
      )

    Phoenix.Component.assign(socket, :presences, presences)
  end
end
