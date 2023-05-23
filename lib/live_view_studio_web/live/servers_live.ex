defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        servers: Servers.list_servers(),
        form: to_form(Servers.change_server(%Server{})),
        coffees: 0
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)
    socket = assign(socket, selected_server: server, page_title: server.name)
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket = assign(socket, selected_server: hd(socket.assigns.servers))
    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}

      {:ok, server} ->
        socket = update(socket, :servers, &[server | &1])
        changeset = Servers.change_server(%Server{})
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
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
          <.server_form form={@form} />
          <.server server={@selected_server} />
          <div class="links">
            <.link navigate={~p"/light"}>Adjust lights</.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def server_form(assigns) do
    ~H"""
    <.form for={@form} phx-submit="save" autocomplete="off">
      <div class="field">
        <.input field={@form[:name]} label="Name" />
      </div>
      <div class="field">
        <.input field={@form[:framework]} label="Framework" />
      </div>
      <div class="field">
        <.input field={@form[:size]} label="Size (MB)" type="number" />
      </div>
      <div class="field">
        <.button phx-disable-with="Saving...">Save</.button>
      </div>
    </.form>
    """
  end

  attr :server, :map

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <span class={@server.status}>
          <%= @server.status %>
        </span>
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
