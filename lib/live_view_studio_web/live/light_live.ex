defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, brightness: 10, temp: 3000)}
  end

  def render(assigns) do
    ~H"""
    <h1>
      Front Porch Light
    </h1>
    <div id="light">
      <div class="meter">
        <span style={ "width: #{@brightness}%; background-color: #{temp_color(@temp)};" }>
          <span class="pl-2">
            <%= @brightness %>%
          </span>
        </span>
      </div>
      <button phx-click="off">
        <img src="/images/light-off.svg" alt="" />
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" alt="" />
      </button>
      <button phx-click="random">
        <img src="/images/fire.svg" alt="" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" alt="" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" alt="" />
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
        <div class="temps">
          <div>
            <%= for temp <- 3000..5000//1000 do %>
              <label>
                <input
                  type="radio"
                  name="temp"
                  value={temp}
                  checked={temp === @temp}
                  class="mr-2"
                /><%= temp %>
              </label>
            <% end %>
          </div>
        </div>
      </form>
    </div>
    """
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"

  def handle_event("update", %{"brightness" => brightness, "temp" => temp}, socket) do
    socket =
      assign(socket,
        brightness: String.to_integer(brightness),
        temp: String.to_integer(temp)
      )

    {:noreply, socket}
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
