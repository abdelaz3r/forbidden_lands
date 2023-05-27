defmodule ForbiddenLandsWeb.Components.Generic.Icon do
  use Phoenix.Component

  attr(:name, :atom, required: true)
  attr(:class, :string, default: "")

  @doc """
  A dynamic way of generating a Lucide icon.

  Example:

      <.icon name={:arrow_right} class="w-5 h-5 text-gray-600 dark:text-gray-400" />
  """
  @spec icon(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def icon(assigns) do
    apply(Lucide, assigns.name, [assigns])
  end
end
