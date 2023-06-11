defmodule LiveViewStudioWeb.ShopLive do
  use LiveViewStudioWeb, :live_view

  alias Phoenix.LiveView.JS
  alias LiveViewStudio.Products

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       products: Products.list_products(),
       cart: %{}
     )}
  end

  def handle_event("add-product", %{"product" => product}, socket) do
    cart = Map.update(socket.assigns.cart, product, 1, &(&1 + 1))
    {:noreply, assign(socket, :cart, cart)}
  end

  defp toggle_cart() do
    JS.toggle(to: "#cart") |> JS.toggle(to: "#backdrop")
  end

  def render(assigns) do
    ~H"""
    <h1>Mike's Garage Sale</h1>
    <div id="shop">
      <div class="nav">
        <button
          :if={Enum.count(@cart) > 0}
          phx-click={toggle_cart()}
          id="cart-button"
        >
          <.icon name="hero-shopping-cart" />
          <span class="count">
            <%= Enum.count(@cart) %>
          </span>
        </button>
      </div>

      <div class="products">
        <div :for={product <- @products} class="product">
          <div class="image">
            <%= product.image %>
          </div>
          <div class="name">
            <%= product.name %>
          </div>
          <button phx-click="add-product" phx-value-product={product.image}>
            Add
          </button>
        </div>
      </div>

      <div id="backdrop" class="hidden" phx-click={toggle_cart()}></div>

      <div id="cart" class="hidden">
        <div class="content">
          <div class="header">
            <h2>Shopping Cart</h2>
            <button phx-click={toggle_cart()}>
              <.icon name="hero-x-mark" />
            </button>
          </div>
          <ul>
            <li :for={{product, quantity} <- @cart}>
              <span class="product">
                <%= product %>
              </span>
              <span class="quantity">
                &times; <%= quantity %>
              </span>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
