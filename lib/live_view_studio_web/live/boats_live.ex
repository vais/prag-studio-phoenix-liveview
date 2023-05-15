defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats

  import LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [boats: []]}
  end

  def handle_params(params, _url, socket) do
    filter = %{
      type: params["type"] || "",
      prices: params["prices"] || [""]
    }

    boats = Boats.list_boats(filter)

    socket =
      assign(socket,
        filter: filter,
        boats: boats
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>

    <.promo expires={1} seconds={3}>
      Save 25% on rentals!
      <:legal>
        <Heroicons.exclamation_circle /> Only 1 per party
      </:legal>
    </.promo>

    <div id="boats">
      <.filter_form filter={@filter} />
      <div class="boats">
        <.boat_card :for={boat <- @boats} boat={boat} />
      </div>
    </div>

    <.promo>
      Hurry, only <%= Enum.count(@boats) %> <%= @filter.type %> boats left!
    </.promo>
    """
  end

  attr :boat, Boats.Boat, required: true

  defp boat_card(assigns) do
    ~H"""
    <div class="boat">
      <img src={@boat.image} />
      <div class="content">
        <div class="model">
          <%= @boat.model %>
        </div>
        <div class="details">
          <span class="price">
            <%= @boat.price %>
          </span>
          <span class="type">
            <%= @boat.type %>
          </span>
        </div>
      </div>
    </div>
    """
  end

  attr :filter, :map, required: true

  defp filter_form(assigns) do
    ~H"""
    <form phx-change="filter">
      <div class="filters">
        <select name="type">
          <%= Phoenix.HTML.Form.options_for_select(
            type_options(),
            @filter.type
          ) %>
        </select>
        <div class="prices">
          <%= for price <- ["$", "$$", "$$$"] do %>
            <input
              type="checkbox"
              name="prices[]"
              value={price}
              id={price}
              checked={price in @filter.prices}
            />
            <label for={price}><%= price %></label>
          <% end %>
          <input type="hidden" name="prices[]" value="" />
        </div>
      </div>
    </form>
    """
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end

  def handle_event("filter", params, socket) do
    params = Map.take(params, ["type", "prices"])
    socket = push_patch(socket, to: ~p"/boats?#{params}")
    {:noreply, socket}
  end
end
