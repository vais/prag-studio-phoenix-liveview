defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [pizza_orders: []]}
  end

  def handle_params(params, _uri, socket) do
    options = %{
      sort_by: valid_sort_by(params),
      sort_order: valid_sort_order(params)
    }

    socket =
      assign(socket,
        pizza_orders: PizzaOrders.list_pizza_orders(options),
        options: options
      )

    {:noreply, socket}
  end

  defp valid_sort_by(%{"sort_by" => sort_by} = _params)
       when sort_by in ~w(id size style topping_1 topping_2 price),
       do: String.to_atom(sort_by)

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order} = _params)
       when sort_order in ~w(asc desc),
       do: String.to_atom(sort_order)

  defp valid_sort_order(_params), do: :asc

  defp sort_link(assigns) do
    assigns =
      assign(assigns, :query_string,
        sort_by: assigns.sort_by,
        sort_order: flip_sort_order(assigns.options.sort_order)
      )

    ~H"""
    <.link patch={~p"/pizza-orders?#{@query_string}"}>
      <%= render_slot(@inner_block) %>
      <.sort_order_indicator
        :if={@sort_by == @options.sort_by}
        sort_order={@options.sort_order}
      />
    </.link>
    """
  end

  defp sort_order_indicator(%{sort_order: :desc} = assigns), do: ~H"<span>⬇️</span>"
  defp sort_order_indicator(%{sort_order: :asc} = assigns), do: ~H"<span>⬆️</span>"

  defp flip_sort_order(:asc), do: :desc
  defp flip_sort_order(:desc), do: :asc
end
