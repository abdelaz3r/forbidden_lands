defmodule ForbiddenLandsWeb.Live.Home do
  @moduledoc """
  Home view
  """
  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Utils.RomanNumerals

  use ForbiddenLandsWeb, :live_view

  @current_quarter 1_701_993

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    now = Calendar.from_quarters(@current_quarter)
    quarter_shift = now.count.quarters - rem(now.count.quarters - 1, 4)

    {:ok, assign(socket, now: now, quarter_shift: quarter_shift)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-[1fr_400px] h-screen bg-slate-700">
      <div class="flex items-stretch">
        <div class="grow m-6 border border-white/20 border-dashed rounded-lg flex justify-center items-center">
          <h1 class="font-title font-bold text-4xl text-white/20">
            Carte des Forbidden Lands
          </h1>
        </div>
      </div>

      <div class="bg-slate-800 shadow-xl shadow-black/50 overflow-hidden">
        <div class="font-title text-slate-100 border-b border-slate-900 shadow-xl mb-10">
          <div class="flex items-stretch gap-4 p-4">
            <div class="relative overflow-hidden w-16 h-16 flex-none flex items-center text-3xl justify-center bg-rose-500 border border-rose-500 shadow-inner shadow-rose-700 rounded-full outline outline-offset-2 outline-2 outline-rose-500/30">
              <span class="absolute z-10 text-white font-bold"><%= @now.month.day %></span>
              <span
                class="absolute inset-0 transition-all duration-500"
                style={"transform: rotate(#{((@now.count.quarters - @quarter_shift) * 90) + 45}deg);"}
              >
                <span class="absolute w-1/2 h-1/2 border border-rose-900/70 bg-rose-900/50 shadow-inner shadow-rose-900 top-0 right-0">
                </span>
              </span>
            </div>
            <div class="grow">
              <div class="flex justify-between items-end text-lg font-bold">
                <span>
                  <%= @now.month.name |> String.capitalize() %>
                  <span class="inline-block leading-5 px-1.5 text-sm bg-slate-900 rounded text-slate-100/40">
                    <%= RomanNumerals.convert(@now.month.number) %>
                  </span>
                </span>
                <span class="flex items-center gap-2">
                  <%= @now.year.number %>
                  <span class="text-slate-100/20">A.S.</span>
                  <span>
                    <Heroicons.sparkles :if={@now.season.key == :spring} mini class="w-4 text-emerald-500" />
                    <Heroicons.sun :if={@now.season.key == :summer} mini class="w-4 text-amber-400" />
                    <Heroicons.bars_3_center_left :if={@now.season.key == :fall} mini class="w-4 text-amber-800" />
                    <Heroicons.cloud :if={@now.season.key == :winter} mini class="w-4 text-slate-300" />
                  </span>
                </span>
              </div>
              <div class="text-sm">
                <span><%= @now.day.name |> String.capitalize() %></span>
                <span class="opacity-40">(<%= @now.day.ref %>)</span>
              </div>
              <div class="text-sm">
                <span><%= @now.quarter.name |> String.capitalize() %></span>,
                <span class="opacity-40"><%= @now.quarter.description %></span>
              </div>
            </div>
          </div>
          <div class="h-0.5 w-full bg-slate-900/20">
            <div class="h-0.5 bg-rose-500 transition-all duration-500" style={"width: #{Calendar.month_progression(@now)}%;"}></div>
          </div>
          <div class="text-sm flex items-center justify-between p-4">
            <div>
              <%= Calendar.luminosity(@now).name |> String.capitalize() %>
            </div>
            <div class="flex items-center gap-3 text-slate-100/40">
              <%= @now.moon.name |> String.capitalize() %>
              <span class="flex" style={"opacity: #{Calendar.moon_progression(@now)}%;"}>
                <span :if={@now.moon.key == :new} class="w-4 h-4 bg-amber-100 rounded-full"></span>
                <Heroicons.moon :if={@now.moon.key == :first} mini class="w-4 text-amber-100" />
                <span :if={@now.moon.key == :full} class="w-4 h-4 bg-amber-100 rounded-full"></span>
                <Heroicons.moon :if={@now.moon.key == :last} mini class="w-4 text-amber-100 rotate-90" />
              </span>
            </div>
          </div>
        </div>

        <div class="flex flex-wrap p-4 gap-2 mb-10">
          <button
            :for={amount <- [1, 4, 28, 180, 1460, -1, -4, -28, -180, -1460]}
            type="button"
            phx-click="move"
            phx-value-amount={amount}
            phx-value-type="quarter"
            class="block p-2 bg-slate-700 rounded"
          >
            <%= amount %> Quarter
          </button>
        </div>

        <div class="p-4 mb-10 text-slate-400">
          <%= inspect(@now) %>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("move", %{"amount" => amount, "type" => type}, socket) do
    amount = String.to_integer(amount)
    type = String.to_existing_atom(type)
    now = Calendar.add(socket.assigns.now, amount, type)

    {:noreply, assign(socket, now: now)}
  end
end
