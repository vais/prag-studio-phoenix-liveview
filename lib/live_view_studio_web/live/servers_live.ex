defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudioWeb.ServerForm

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Servers.subscribe()
    end

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

    {:noreply, assign(socket, :selected_server, server)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    {:ok, _server} = Servers.delete_server(server)
    {:noreply, socket}
  end

  def handle_info({:server_created, server}, socket) do
    {:noreply, update(socket, :servers, &[server | &1])}
  end

  def handle_info({:server_updated, server}, socket) do
    socket =
      assign(
        socket,
        :servers,
        Enum.map(socket.assigns.servers, fn s ->
          if s.id == server.id, do: server, else: s
        end)
      )

    if server.id == socket.assigns.selected_server.id do
      {:noreply, assign(socket, :selected_server, server)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:server_deleted, server}, socket) do
    servers = socket.assigns.servers
    selected_server = socket.assigns.selected_server

    socket = assign(socket, :servers, Enum.reject(servers, &(&1.id == server.id)))

    if selected_server && selected_server.id == server.id do
      {:noreply, push_patch(socket, to: ~p"/servers")}
    else
      {:noreply, socket}
    end
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
            <.link navigate={~p"/topsecret"}>Top Secret</.link>
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
        <button
          phx-click="delete"
          phx-value-id={@server.id}
          data-confirm="Are you 100% sure?"
          class="bg-transparent hover:bg-red-500 text-red-700 font-semibold hover:text-white py-2 px-4 border border-red-500 hover:border-transparent rounded"
        >
          Delete <%= @server.name %>
        </button>
      </div>
    </div>
    """
  end
end
