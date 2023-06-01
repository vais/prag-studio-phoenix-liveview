defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudioWeb.ServerForm

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        servers: Servers.list_servers(),
        coffees: 0
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)
    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    server = hd(socket.assigns.servers)

    assign(socket,
      selected_server: server,
      page_title: server.name
    )
  end

  defp apply_action(socket, :new, _params) do
    assign(socket,
      selected_server: nil,
      page_title: "New Server"
    )
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    server = Servers.get_server!(id)

    assign(socket,
      selected_server: server,
      page_title: server.name
    )
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)

    {:ok, server} =
      Servers.update_server(
        server,
        %{status: if(server.status == "up", do: "down", else: "up")}
      )

    socket =
      assign(socket,
        selected_server: server,
        servers:
          Enum.map(socket.assigns.servers, fn s ->
            if s.id == server.id, do: server, else: s
          end)
      )

    {:noreply, socket}
  end

  def handle_info({ServerForm, :server_created, server}, socket) do
    socket =
      socket
      |> update(:servers, &[server | &1])
      |> push_patch(to: ~p"/servers/#{server}")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>
          <.link
            :for={server <- @servers}
            class={if server == @selected_server, do: "selected"}
            patch={~p"/servers/#{server}"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @selected_server do %>
            <.server server={@selected_server} />
          <% else %>
            <.live_component module={ServerForm} id="new" />
          <% end %>
          <div class="links">
            <.link navigate={~p"/light"}>Adjust lights</.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :server, :map

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <button
          phx-click="toggle-status"
          phx-value-id={@server.id}
          class={@server.status}
        >
          <%= @server.status %>
        </button>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @server.deploy_count %> deploys
          </span>
          <span>
            <%= @server.size %> MB
          </span>
          <span>
            <%= @server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end
end
