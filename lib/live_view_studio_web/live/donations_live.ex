defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    options = %{
      sort_by: valid_sort_by(params),
      sort_order: valid_sort_order(params)
    }

    socket =
      assign(
        socket,
        donations: Donations.list_donations(options),
        options: options
      )

    {:noreply, socket}
  end

  defp valid_sort_by(%{"sort_by" => sort_by} = _params)
       when sort_by in ~w(item quantity days_until_expires),
       do: String.to_atom(sort_by)

  defp valid_sort_by(_sort_by), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order} = _params)
       when sort_order in ~w(asc desc),
       do: String.to_atom(sort_order)

  defp valid_sort_order(_sort_order), do: :asc

  defp flip_sort_order(:asc), do: :desc
  defp flip_sort_order(:desc), do: :asc

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  defp sort_link(assigns) do
    ~H"""
    <.link patch={
      ~p"/donations?#{[sort_by: @sort_by, sort_order: flip_sort_order(@options.sort_order)]}"
    }>
      <%= render_slot(@inner_block) %>
      <.sort_order_indicator
        :if={@sort_by == @options.sort_by}
        sort_order={@options.sort_order}
      />
    </.link>
    """
  end

  defp sort_order_indicator(%{sort_order: :asc} = assigns) do
    ~H"<span>⬆️</span>"
  end

  defp sort_order_indicator(%{sort_order: :desc} = assigns) do
    ~H"<span>⬇️</span>"
  end
end
