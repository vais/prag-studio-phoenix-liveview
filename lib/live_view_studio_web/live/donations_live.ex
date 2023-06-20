defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    options = %{
      sort_by: valid_sort_by(params),
      sort_order: valid_sort_order(params),
      page: param_to_integer(params["page"], 1),
      per_page: param_to_integer(params["per_page"], 10)
    }

    socket =
      assign(
        socket,
        donations: Donations.list_donations(options),
        donation_count: Donations.count_donations(),
        options: options
      )

    {:noreply, socket}
  end

  def goto_page(socket, page) do
    params = %{socket.assigns.options | page: page}
    {:noreply, push_patch(socket, to: ~p"/donations?#{params}")}
  end

  def next_page(socket, _more_pages = true) do
    goto_page(socket, socket.assigns.options.page + 1)
  end

  def next_page(socket, _more_pages = false) do
    {:noreply, socket}
  end

  def prev_page(socket, _more_pages = true) do
    goto_page(socket, socket.assigns.options.page - 1)
  end

  def prev_page(socket, _more_pages = false) do
    {:noreply, socket}
  end

  def handle_event("window-keyup", %{"key" => "ArrowRight"}, socket) do
    next_page(socket, more_pages?(socket.assigns.donation_count, socket.assigns.options))
  end

  def handle_event("window-keyup", %{"key" => "ArrowLeft"}, socket) do
    prev_page(socket, socket.assigns.options.page > 1)
  end

  def handle_event("window-keyup", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per_page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    socket = push_patch(socket, to: ~p"/donations?#{params}")
    {:noreply, socket}
  end

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {integer, _rest} -> integer
      :error -> default
    end
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

  defp pager(donation_count, options) do
    max(options.page - 2, 1)..min(options.page + 2, ceil(donation_count / options.per_page))
  end

  defp more_pages?(donation_count, options) do
    donation_count > options.page * options.per_page
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  defp sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: flip_sort_order(assigns.options.sort_order)
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={~p"/donations?#{@params}"}>
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
