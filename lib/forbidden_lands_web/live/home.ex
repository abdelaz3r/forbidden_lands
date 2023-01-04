defmodule ForbiddenLandsWeb.Live.Home do
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
    <div>
      TODO
    </div>
    """
  end
end
