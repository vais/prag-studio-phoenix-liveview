defmodule LiveViewStudioWeb.BingoLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudioWeb.Presence

  @topic "users:bingo"

  def mount(_params, _session, socket) do
    socket = assign(socket, number: nil, numbers: all_numbers())
    socket = assign(socket, :presences, Presence.list_users(@topic))

    if connected?(socket) do
      :ok = Presence.subscribe(@topic)

      {:ok, _ref} =
        Presence.track_user(socket.assigns.current_user, @topic, %{
          timestamp: Timex.now("America/New_York") |> Timex.format!("%H:%M", :strftime)
        })

      :timer.send_interval(1000, self(), :pick)

      {:ok, pick(socket)}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Bingo Boss 📢</h1>
    <h2><%= @current_user.email %></h2>
    <div id="bingo">
      <div class="users">
        <ul>
          <li :for={{_user_id, meta} <- @presences}>
            <span class="username"><%= meta.username %></span>
            <span class="timestamp"><%= meta.timestamp %></span>
          </li>
        </ul>
      </div>
      <div class="number">
        <%= @number %>
      </div>
    </div>
    """
  end

  # Assigns the next random bingo number, removing it
  # from the assigned list of numbers. Resets the list
  # when the last number has been picked.
  def pick(socket) do
    case socket.assigns.numbers do
      [head | []] ->
        assign(socket, number: head, numbers: all_numbers())

      [head | tail] ->
        assign(socket, number: head, numbers: tail)
    end
  end

  # Returns a list of all valid bingo numbers in random order.
  #
  # Example: ["B 4", "N 40", "O 73", "I 29", ...]
  def all_numbers() do
    ~w(B I N G O)
    |> Enum.zip(Enum.chunk_every(1..75, 15))
    |> Enum.flat_map(fn {letter, numbers} ->
      Enum.map(numbers, &"#{letter} #{&1}")
    end)
    |> Enum.shuffle()
  end

  def handle_info(:pick, socket) do
    {:noreply, pick(socket)}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end
end
