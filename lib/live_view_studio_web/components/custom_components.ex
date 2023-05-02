defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  attr :expires, :integer, default: 24
  slot :inner_block, required: true
  slot :legal

  def promo(assigns) do
    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">
        Deal expires in <%= plural("hour", @expires) %>
      </div>
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end

  defp plural("hour", 1), do: "1 hour"
  defp plural("hour", n), do: "#{n} hours"
end
