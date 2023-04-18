defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, brightness: 10)}
  end

  def render(assigns) do
    ~H"""
    <h1>
      Front Porch Light
    </h1>
    <div id="light">
      <div class="meter">
        <span style={ "width: #{@brightness}%;" }>
          <span style="padding: 0 10px">
            <%= @brightness %>%
          </span>
        </span>
      </div>
      <button phx-click="off">
        <img src="images/light-off.svg" alt="" />
      </button>
      <button phx-click="down">
        <img src="images/down.svg" alt="" />
      </button>
      <button phx-click="random">
        <img src="images/fire.svg" alt="" />
      </button>
      <button phx-click="up">
        <img src="images/up.svg" alt="" />
      </button>
      <button phx-click="on">
        <img src="images/light-on.svg" alt="" />
      </button>
      <form phx-change="update">
        <input
          type="range"
          name="brightness"
          value={@brightness}
          min="0"
          max="100"
          step="10"
        />
      </form>
    </div>
    """
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    {:noreply, assign(socket, :brightness, String.to_integer(brightness))}
  end

  def handle_event("random", _, socket) do
    {:noreply, assign(socket, :brightness, Enum.random(0..100//10))}
  end

  def handle_event("on", _, socket) do
    {:noreply, assign(socket, :brightness, 100)}
  end

  def handle_event("off", _, socket) do
    {:noreply, assign(socket, :brightness, 0)}
  end

  def handle_event("up", _, socket) do
    {:noreply, update(socket, :brightness, &min(&1 + 10, 100))}
  end

  def handle_event("down", _, socket) do
    {:noreply, update(socket, :brightness, &max(&1 - 10, 0))}
  end
end
