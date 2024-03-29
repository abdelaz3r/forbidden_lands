defmodule ForbiddenLandsWeb.Live.Dashboard.Header do
  @moduledoc """
  TODO.
  """

  use ForbiddenLandsWeb, :html

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Utils.RomanNumerals

  attr(:date, Calendar, required: true, doc: "todo")
  attr(:quarter_shift, :integer, required: true, doc: "todo")
  attr(:class, :string, default: "", doc: "todo")

  @spec header(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def header(assigns) do
    ~H"""
    <div class={[
      "bg-gradient-to-r from-grey-800 to-grey-900 flex-none z-10 border-b border-grey-900 shadow-2xl shadow-black/50",
      @class
    ]}>
      <div class="flex items-stretch gap-4 p-4">
        <div class="relative overflow-hidden w-16 h-16 flex-none flex items-center text-3xl justify-center bg-accent-600 border border-accent-500 shadow-inner shadow-accent-700 rounded-full outline outline-offset-2 outline-2 outline-accent-500/30">
          <span class="absolute z-10 text-white font-bold">
            <%= @date.month.day %>
          </span>
          <span
            class="absolute inset-0 transition-all duration-500"
            style={"transform: rotate(#{((@date.count.quarters - @quarter_shift) * 90) + 45}deg);"}
          >
            <span class="absolute w-1/2 h-1/2 border border-accent-900 bg-accent-900/80 shadow-inner shadow-accent-900 top-0 right-0">
            </span>
          </span>
          <div class="absolute inset-0 rotate-45">
            <span class="absolute w-1/2 h-1/2 border border-accent-900/40 bottom-0 left-0"></span>
            <span class="absolute w-1/2 h-1/2 border border-accent-900/40 top-0 right-0"></span>
          </div>
        </div>
        <div class="grow">
          <div class="flex justify-between items-end text-lg font-bold">
            <span>
              <%= @date.month.name |> String.capitalize() %>
              <span class="inline-block leading-5 px-1.5 text-sm bg-grey-900 rounded text-grey-100/80">
                <%= RomanNumerals.convert(@date.month.number) %>
              </span>
            </span>
            <span class="flex items-center gap-2">
              <%= @date.year.number %>
              <span class="text-grey-100/40">A.S.</span>
              <span>
                <.icon :if={@date.season.key == :spring} name={:flower} class="w-4 h-4 text-emerald-500" />
                <.icon :if={@date.season.key == :summer} name={:sun} class="w-4 h-4 text-amber-400" />
                <.icon :if={@date.season.key == :fall} name={:leaf} class="w-4 h-4 text-amber-800" />
                <.icon :if={@date.season.key == :winter} name={:snowflake} class="w-4 h-4 text-grey-300" />
              </span>
            </span>
          </div>
          <div class="text-sm">
            <span><%= @date.day.name |> String.capitalize() %></span>
            <span class="opacity-60">(<%= @date.day.ref %>)</span>
          </div>
          <div class="text-sm">
            <span><%= @date.quarter.name |> String.capitalize() %></span>,
            <span class="opacity-60"><%= @date.quarter.description %></span>
          </div>
        </div>
      </div>
      <div class="h-0.5 w-full bg-grey-900/20">
        <div class="h-0.5 bg-accent-500 transition-all duration-500" style={"width: #{Calendar.month_progression(@date)}%;"}></div>
      </div>
      <div class="text-sm flex items-center justify-between p-4">
        <div>
          <%= dgettext("app", "It's %{luminosity}", luminosity: Calendar.luminosity(@date).name) %>
        </div>
        <div class="flex items-center gap-3 text-grey-100/60">
          <%= @date.moon.name |> String.capitalize() %>
          <span class="flex" style={"opacity: #{Calendar.moon_progression(@date)}%;"}>
            <span :if={@date.moon.key == :new} class="w-4 h-4 bg-amber-100 rounded-full"></span>
            <.icon :if={@date.moon.key == :first} name={:moon} class="w-4 h-4 text-amber-100" />
            <span :if={@date.moon.key == :full} class="w-4 h-4 bg-amber-100 rounded-full"></span>
            <.icon :if={@date.moon.key == :last} name={:moon} class="w-4 h-4 text-amber-100 rotate-90" />
          </span>
        </div>
      </div>
    </div>
    """
  end
end
