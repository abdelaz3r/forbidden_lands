defmodule ForbiddenLandsWeb.Live.Story do
  @moduledoc """
  Story of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Instances.Instances
  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Calendar

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    with {:ok, instance} <- Instances.get(id),
         events <- Instances.get_events(id, Event.types()) do
      events = add_calendar_to_events(events)
      types = Enum.map(Event.types(), fn type -> %{type: type, active?: true} end)

      socket =
        socket
        |> assign(page_title: instance.name)
        |> assign(instance: instance)
        |> assign(events: events)
        |> assign(types: types)

      {:ok, socket}
    else
      {:error, _reason} ->
        socket =
          socket
          |> push_navigate(to: ~p"/")
          |> put_flash(:error, "Cette instance n'existe pas")

        {:ok, socket}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="text-slate-900 font-title p-0 md:py-[40vh] bg-fixed bg-center bg-no-repeat bg-cover md:bg-[url('/images/story-background.jpg')]">
      <div class="relative max-w-[800px] mx-auto">
        <.background_sheets />

        <div class="flex flex-col items-center gap-1 py-1 absolute bg-stone-200 z-10 w-10 -left-10 top-24 shadow-2xl">
          <button
            :for={%{type: type, active?: active?} <- @types}
            type="button"
            phx-click="update_types"
            phx-value-type={type}
            class={not active? && "opacity-20"}
          >
            <.event_type_icon type={type} />
          </button>
        </div>

        <div class={["relative bg-stone-200 shadow-2xl p-5 z-20 pb-36", border_classes()]}>
          <div class="text-center">
            <header class="inline-block m-auto px-4 py-[25vh]">
              <h2 class="inline-block pb-2 text-2xl text-slate-900/50">
                The full story of
              </h2>
              <br />
              <h1 class="
                inline relative text-5xl font-bold first-letter:text-6xl text-stone-800
                after:hidden md:after:block after:absolute after:-right-10 after:bottom-1 after:h-[2px] after:w-[200px] after:bg-slate-600/10 after:z-[-1]
              ">
                <%= @instance.name %>
              </h1>
              <br />
              <h2 class="inline-block pt-2 text-2xl">
                [subtitle]
              </h2>
            </header>
          </div>

          <div :for={{%{event: event, calendar: calendar}, i} <- Enum.with_index(@events)}>
            <div
              :if={i == 0 or Enum.at(@events, i - 1).calendar.month.number != calendar.month.number}
              class="relative text-4xl font-bold px-16 md:px-36 py-10"
            >
              <%= String.capitalize(calendar.month.name) %>
              <%= calendar.year.number %>
            </div>

            <section class="px-4 md:px-36 space-y-2 pb-6">
              <a href={~p"/adventure/#{@instance.id}/story#event-#{event.id}"} id={"event-#{event.id}"} class="relative flex items-center gap-4">
                <div
                  :if={i == 0 or Enum.at(@events, i - 1).calendar.month.day != calendar.month.day}
                  class="md:absolute md:-left-14 md:top-2 flex-none inline-flex justify-center items-center w-12 h-12 rounded-full text-2xl border border-stone-300/80"
                >
                  <%= calendar.month.day %>
                </div>
                <div class="">
                  <span class="relative text-xs text-stone-700/70 uppercase top-1">
                    <%= String.capitalize(calendar.quarter.name) %>
                  </span>
                  <h2 class="text-2xl font-bold">
                    <%= event.title %>
                  </h2>
                </div>
              </a>

              <div :if={not is_nil(event.description)} class="text-lg space-y-2">
                <%= Helper.text_to_raw_html(event.description) |> raw() %>
              </div>
            </section>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("update_types", %{"type" => type_param}, socket) do
    type_param = String.to_existing_atom(type_param)

    types =
      Enum.map(socket.assigns.types, fn %{type: type, active?: active?} = item ->
        if type == type_param,
          do: %{item | active?: not active?},
          else: item
      end)

    types_atom =
      types
      |> Enum.filter(fn %{active?: active?} -> active? end)
      |> Enum.map(fn %{type: type} -> type end)

    events =
      socket.assigns.instance.id
      |> Instances.get_events(types_atom)
      |> add_calendar_to_events()

    socket =
      socket
      |> assign(events: events)
      |> assign(types: types)

    {:noreply, socket}
  end

  defp add_calendar_to_events(events) do
    Enum.map(events, fn event ->
      %{event: event, calendar: Calendar.from_quarters(event.date)}
    end)
  end

  defp background_sheets(assigns) do
    ~H"""
    <div class={["w-[300px] -right-16 -top-16 h-[600px] rotate-3", background_classes(), border_classes()]}></div>
    <div class={["w-[300px] -left-20 top-32 h-[600px] -rotate-6", background_classes(), border_classes()]}></div>
    <div class={["w-full -left-2 -top-3 h-[800px] -rotate-1", background_classes()]}></div>
    <div class={["w-full left-1 -top-3 h-[600px] rotate-1", background_classes()]}></div>
    """
  end

  defp background_classes() do
    "hidden md:block absolute bg-stone-200 shadow-xl z-10"
  end

  defp border_classes() do
    "before:absolute before:inset-4 before:border before:border-4 before:border-double before:border-stone-300/80 before:z-[-1]"
  end

  defp event_type_icon(%{type: :automatic} = assigns) do
    ~H"""
    <Heroicons.bars_2 class={[event_icon_class()]} />
    """
  end

  defp event_type_icon(%{type: :normal} = assigns) do
    ~H"""
    <Heroicons.bars_3_bottom_left class={[event_icon_class()]} />
    """
  end

  defp event_type_icon(%{type: :special} = assigns) do
    ~H"""
    <Heroicons.star class={[event_icon_class()]} />
    """
  end

  defp event_type_icon(%{type: :legendary} = assigns) do
    ~H"""
    <Heroicons.sparkles class={[event_icon_class()]} />
    """
  end

  defp event_type_icon(%{type: :death} = assigns) do
    ~H"""
    <Heroicons.hand_raised class={[event_icon_class()]} />
    """
  end

  defp event_icon_class(), do: "w-8 p-1.5 rounded-full border text-slate-900/70 hover:text-slate-900"
end
