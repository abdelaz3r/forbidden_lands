defmodule ForbiddenLandsWeb.Live.Calendar do
  @moduledoc """
  Home view
  """
  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Utils.RomanNumerals

  use ForbiddenLandsWeb, :live_view

  @current_quarter 1_770_890

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    now = Calendar.from_quarters(@current_quarter)
    start_moon = Calendar.add(now, -14, :day)
    start_year = Calendar.start_of(now, :year)

    dates = [
      %{
        label: "Playground",
        dates: [
          %{label: "Init (1 quarter)", date: Calendar.from_quarters(1)},
          %{label: "Now (1 770 890 quarters)", date: now},
          %{label: "+1 quarter", date: Calendar.add(now, 1, :quarter)},
          %{label: "+1 day", date: Calendar.add(now, 1, :day)},
          %{label: "+1 week", date: Calendar.add(now, 1, :week)},
          %{label: "+1 year", date: Calendar.add(now, 1, :year)},
          %{label: "+200 days", date: Calendar.add(now, 200, :day)},
          %{label: "+250 days", date: Calendar.add(now, 250, :day)},
          # separator
          %{label: "Begin-1", date: start_year |> Calendar.add(-1, :day)},
          %{label: "Begin", date: start_year},
          %{label: "Begin+1", date: start_year |> Calendar.add(1, :day)},
          # separator
          %{label: "End-1", date: Calendar.end_of(now, :year) |> Calendar.add(-1, :day)},
          %{label: "End", date: Calendar.end_of(now, :year)},
          %{label: "End+1", date: Calendar.end_of(now, :year) |> Calendar.add(1, :day)}
        ]
      },
      %{
        label: "Moonphase",
        dates: Enum.map(0..28, fn i -> %{label: "+#{i}", date: Calendar.add(start_moon, i, :day)} end)
      },
      %{
        label: "Walkthrough",
        dates: Enum.map(0..370//9, fn i -> %{label: "+#{i}", date: Calendar.add(start_year, i, :day)} end)
      }
    ]

    {:ok, assign(socket, dates: dates)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div :for={%{label: label, dates: dates} <- @dates} class="m-10 p-5 shadow-md bg-white w-5/12">
      <h1 class="text-3xl font-title font-bold"><%= label %></h1>

      <div :for={%{label: label, date: date} <- dates} class="py-4 border-b">
        <h2 class="text-lg font-bold pb-3 opacity-10"><%= label %></h2>

        <div class="flex items-stretch gap-2">
          <div class="w-12 flex-none flex items-center text-3xl font-title font-bold justify-center bg-slate-100 border border-slate-200 rounded-md">
            <%= date.month.day %>
          </div>
          <div class="grow">
            <div class="relative flex justify-between items-end text-slate-900">
              <span class="flex gap-4 items-center">
                <span class="text-lg font-title">
                  <%= date.month.name |> String.capitalize() %>
                  <span class="inline-block leading-3 p-1 text-sm font-bold bg-slate-300 rounded opacity-50 mr-4">
                    <%= RomanNumerals.convert(date.month.number) %>
                  </span>
                  <%= date.year.number %>
                  <span class="opacity-30">AS</span>
                </span>
                <span>
                  <Heroicons.sparkles :if={date.season.key == :spring} mini class="w-4 text-lime-500" />
                  <Heroicons.sun :if={date.season.key == :summer} mini class="w-4 text-amber-500" />
                  <Heroicons.bars_3_center_left :if={date.season.key == :fall} mini class="w-4 text-stone-700" />
                  <Heroicons.cloud :if={date.season.key == :winter} mini class="w-4 text-slate-300" />
                </span>
              </span>
              <span class="text-slate-500 text-sm flex gap-2 items-center">
                <%= date.moon.name |> String.capitalize() %>
                <span :if={date.moon.key == :new} class="w-3.5 h-3.5 bg-amber-50 rounded-full"></span>
                <Heroicons.moon :if={date.moon.key == :first} mini class="w-4 text-amber-200" />
                <span :if={date.moon.key == :full} class="w-3.5 h-3.5 bg-amber-200 rounded-full"></span>
                <Heroicons.moon :if={date.moon.key == :last} mini class="w-4 text-amber-200 rotate-90" />
              </span>
            </div>
            <div class="text-sm">
              <%= date.day.name |> String.capitalize() %> (<%= date.day.ref %>), <%= date.quarter.name %>, <%= date.quarter.description %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
