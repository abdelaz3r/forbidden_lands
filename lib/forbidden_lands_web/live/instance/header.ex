defmodule ForbiddenLandsWeb.Live.Instance.Header do
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
    <div class={["font-title text-slate-100 border-b border-slate-900 shadow-2xl shadow-black/60", @class]}>
      <div class="flex items-stretch gap-4 p-4">
        <div class="relative overflow-hidden w-16 h-16 flex-none flex items-center text-3xl justify-center bg-rose-500 border border-rose-500 shadow-inner shadow-rose-700 rounded-full outline outline-offset-2 outline-2 outline-rose-500/30">
          <span class="absolute z-10 text-white font-bold"><%= @date.month.day %></span>
          <span
            class="absolute inset-0 transition-all duration-500"
            style={"transform: rotate(#{((@date.count.quarters - @quarter_shift) * 90) + 45}deg);"}
          >
            <span class="absolute w-1/2 h-1/2 border border-rose-900/70 bg-rose-900/50 shadow-inner shadow-rose-900 top-0 right-0">
            </span>
          </span>
        </div>
        <div class="grow">
          <div class="flex justify-between items-end text-lg font-bold">
            <span>
              <%= @date.month.name |> String.capitalize() %>
              <span class="inline-block leading-5 px-1.5 text-sm bg-slate-900 rounded text-slate-100/40">
                <%= RomanNumerals.convert(@date.month.number) %>
              </span>
            </span>
            <span class="flex items-center gap-2">
              <%= @date.year.number %>
              <span class="text-slate-100/20">A.S.</span>
              <span>
                <Heroicons.sparkles :if={@date.season.key == :spring} mini class="w-4 text-emerald-500" />
                <Heroicons.sun :if={@date.season.key == :summer} mini class="w-4 text-amber-400" />
                <Heroicons.bars_3_center_left :if={@date.season.key == :fall} mini class="w-4 text-amber-800" />
                <Heroicons.cloud :if={@date.season.key == :winter} mini class="w-4 text-slate-300" />
              </span>
            </span>
          </div>
          <div class="text-sm">
            <span><%= @date.day.name |> String.capitalize() %></span>
            <span class="opacity-40">(<%= @date.day.ref %>)</span>
          </div>
          <div class="text-sm">
            <span><%= @date.quarter.name |> String.capitalize() %></span>,
            <span class="opacity-40"><%= @date.quarter.description %></span>
          </div>
        </div>
      </div>
      <div class="h-0.5 w-full bg-slate-900/20">
        <div class="h-0.5 bg-rose-500 transition-all duration-500" style={"width: #{Calendar.month_progression(@date)}%;"}></div>
      </div>
      <div class="text-sm flex items-center justify-between p-4">
        <div>
          <%= Calendar.luminosity(@date).name |> String.capitalize() %>
        </div>
        <div class="flex items-center gap-3 text-slate-100/40">
          <%= @date.moon.name |> String.capitalize() %>
          <span class="flex" style={"opacity: #{Calendar.moon_progression(@date)}%;"}>
            <span :if={@date.moon.key == :new} class="w-4 h-4 bg-amber-100 rounded-full"></span>
            <Heroicons.moon :if={@date.moon.key == :first} mini class="w-4 text-amber-100" />
            <span :if={@date.moon.key == :full} class="w-4 h-4 bg-amber-100 rounded-full"></span>
            <Heroicons.moon :if={@date.moon.key == :last} mini class="w-4 text-amber-100 rotate-90" />
          </span>
        </div>
      </div>
    </div>
    """
  end
end
