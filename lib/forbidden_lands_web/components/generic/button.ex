defmodule ForbiddenLandsWeb.Components.Generic.Button do
  @moduledoc """
  Generic button component.
  You may use this component within a form, or by its own.

  Available style options are:
  :primary, :primary_alt, :secondary (default), :action, :outlined, :ghost

  Usage:
  ```
  <.button
    class="override class list"
    style={:action}
    width={:min}
    underline?={true}>
    Label content
  </.button>
  ```
  """

  use ForbiddenLandsWeb, :html

  @valid_styles ~w(primary primary_alt secondary)a
  @valid_widths ~w(square min auto full)a

  attr(:style, :atom, default: :secondary, values: @valid_styles, doc: "control the appearance")
  attr(:width, :atom, default: :min, values: @valid_widths, doc: "control the width behaviour")
  attr(:underline?, :boolean, default: false, doc: "control is the label is underlined")

  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled x-on:click))

  slot(:inner_block, required: true)

  @spec button(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def button(assigns) do
    ~H"""
    <button
      class={[base_class(), style_class(@style), style_width(@width), style_underline(@underline?), @class]}
      formnovalidate
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp base_class(),
    do: "transition flex items-center gap-2 justify-center min-h-[30px] py-2 focus:outline-none"

  defp style_class(:primary_base),
    do:
      "text-grey-800 bg-rose-500 hover:bg-rose-600 focus:bg-rose-600 active:bg-rose-700 disabled:bg-grey-200 disabled:text-grey-400"

  defp style_class(:primary), do: "#{style_class(:primary_base)} rounded-lg"
  defp style_class(:primary_alt), do: "#{style_class(:primary_base)} rounded-full"

  defp style_class(:secondary),
    do:
      "text-grey-800 rounded-lg bg-sky-400 hover:bg-sky-300 focus:bg-sky-200 active:bg-sky-200 disabled:bg-grey-200 disabled:text-grey-400"

  defp style_width(:square), do: "w-12"
  defp style_width(:min), do: "px-3 w-full md:w-fit md:min-w-[200px]"
  defp style_width(:auto), do: "px-3 w-fit"
  defp style_width(:full), do: "px-3 w-full"

  defp style_underline(true), do: "underline"
  defp style_underline(false), do: ""
end
