defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    options = %{
      sort_by: String.to_existing_atom(params["sort_by"] || "id"),
      sort_order: String.to_existing_atom(params["sort_order"] || "asc")
    }

    socket =
      assign(
        socket,
        donations: Donations.list_donations(options),
        options: options
      )

    {:noreply, socket}
  end

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
