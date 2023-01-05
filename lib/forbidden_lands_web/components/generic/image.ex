defmodule ForbiddenLandsWeb.Components.Generic.Image do
  @moduledoc """
  Default image component.
  """

  use ForbiddenLandsWeb, :html

  attr(:path, :string, required: true)
  attr(:alt, :string, required: true)

  attr(:rest, :global, default: %{class: "inline-block"})

  @spec image(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def image(assigns) do
    ~H"""
    <img src={~p"/images/#{@path}"} alt={@alt} {@rest} />
    """
  end
end
