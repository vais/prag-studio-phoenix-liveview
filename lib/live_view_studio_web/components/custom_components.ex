defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  attr :expires, :integer, default: 24
  attr :seconds, :integer
  slot :inner_block, required: true
  slot :legal

  def promo(assigns) do
    assigns =
      assigns
      |> assign(:minutes, assigns.expires * 60)
      |> assign_new(:seconds, fn %{minutes: minutes} -> minutes * 60 end)

    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">
        Deal expires in <%= plural("hour", @expires) %> (that's <%= @minutes %> minutes)
        (that's <%= @seconds %> seconds)
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
