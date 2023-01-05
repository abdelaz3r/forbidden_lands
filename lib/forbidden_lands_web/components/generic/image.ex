defmodule ForbiddenLandsWeb.Components.Generic.Image do
  @moduledoc """
  Image component.
  Use first the default folder `/images`, put subfolder in the name attribute.
  """

  use ForbiddenLandsWeb, :html

  attr(:path, :string, default: "/images/")
  attr(:name, :string, required: true)
  attr(:alt, :string, required: true)

  attr(:rest, :global, default: %{class: "inline-block"})

  @spec image(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def image(assigns) do
    ~H"""
    <!--
    <img src={Routes.static_path(Endpoint, "#{@path}#{@name}")} alt={@alt} {@rest} />
    -->
    """
  end
end
