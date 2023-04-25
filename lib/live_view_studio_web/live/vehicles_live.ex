defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Vehicles

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        query: "",
        vehicles: [],
        loading: false,
        matches: []
      )

    {:ok, socket}
  end

  def handle_event("autocomplete", %{"query" => prefix}, socket) do
    {:noreply, assign(socket, :matches, Vehicles.suggest(prefix))}
  end

  def handle_event("search", %{"query" => query}, socket) do
    socket =
      assign(socket,
        query: query,
        vehicles: [],
        loading: true
      )

    send(self(), {:search, query})

    {:noreply, socket}
  end

  def handle_info({:search, query}, socket) do
    socket =
      assign(socket,
        vehicles: Vehicles.search(query),
        loading: false
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search">
        <input
          type="text"
          name="query"
          value={@query}
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          readonly={@loading}
          phx-change="autocomplete"
          phx-debounce="300"
          list="matches"
        />

        <button disabled={@loading}>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="matches">
        <option :for={make_model <- @matches} value={make_model}>
          <%= make_model %>
        </option>
      </datalist>

      <div :if={@loading} class="loader">Loading...</div>

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
