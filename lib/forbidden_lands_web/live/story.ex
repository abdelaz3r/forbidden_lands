defmodule ForbiddenLandsWeb.Live.Story do
  @moduledoc """
  Story of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instances

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    with {:ok, instance} <- Instances.get(id, 0) do
      types = Enum.map(Event.types(), fn type -> %{type: type, active?: true} end)

      socket =
        socket
        |> assign(page_title: instance.name)
        |> assign(instance: instance)
        |> assign(types: types)
        |> assign(page: 1)
        |> assign(per_page: 20)
        |> paginate_events()

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
      <h1 class="flex items-center gap-3 absolute top-4 left-3 py-1 px-2 pr-5 font-title font-bold md:text-white text-xl md:drop-shadow-[0_0_5px_rgba(0,0,0,1)]">
        <.link navigate={~p"/"}>
          <.icon name={:chevron_left} class="h-6 w-6" />
        </.link>
        <%= @instance.name %>
      </h1>

      <div class="relative max-w-[800px] mx-auto mt-16 md:mt-0">
        <.background_sheets />

        <div class="flex flex-col items-center gap-1 py-1 absolute bg-stone-200 z-10 w-10 -left-10 top-24 shadow-2xl">
          <button
            :for={%{type: type, active?: active?} <- @types}
            type="button"
            phx-click="update_types"
            phx-value-type={type}
            class={not active? && "opacity-20"}
          >
            <.icon name={Event.icon_by_type(type)} class={event_icon_class()} />
          </button>
        </div>

        <div class={["relative bg-stone-200 shadow-2xl p-8 md:p-5 z-20 pb-36", border_classes()]}>
          <div class="text-center py-20 md:py-[25vh]">
            <header class="inline-block m-auto px-4">
              <h2 :if={@instance.prepend_name} class="inline-block pb-2 text-2xl text-slate-900/50">
                <%= @instance.prepend_name %>
              </h2>
              <br />
              <h1 class="inline relative text-5xl font-bold first-letter:text-6xl text-stone-800">
                <%= @instance.name %>
              </h1>
              <br />
              <h2 :if={@instance.append_name} class="inline-block pt-3 text-2xl">
                <%= @instance.append_name %>
              </h2>
            </header>

            <section :if={@instance.introduction} class="text-left pt-20 md:pt-[25vh] px-4 md:px-36 text-lg space-y-2 italic">
              <%= @instance.introduction %>
            </section>
          </div>

          <div
            id="events"
            phx-update="stream"
            phx-viewport-top={@page > 1 && "prev-page"}
            phx-viewport-bottom={!@end_of_timeline? && "next-page"}
            phx-page-loading
          >
            <div
              :for={{id, %{event: event, with_day: with_day, with_month: with_month, calendar: calendar}} <- @streams.events}
              id={id}
            >
              <div :if={with_month} class="text-4xl text-center md:text-left font-bold px-4 md:px-36 py-10">
                <%= String.capitalize(calendar.month.name) %>
                <%= calendar.year.number %>
              </div>

              <section class="relative px-4 md:px-36 space-y-2 pb-6">
                <a
                  href={~p"/adventure/#{@instance.id}/story#event-#{event.id}"}
                  id={"event-#{event.id}"}
                  class="relative flex items-center gap-4"
                >
                  <div
                    :if={with_day}
                    class="absolute -left-10 md:-left-14 top-6 md:top-2 flex-none inline-flex justify-center items-center w-8 h-8 md:w-12 md:h-12 rounded-full text-xl md:text-2xl bg-stone-200 md:border border-stone-300/80"
                  >
                    <%= calendar.month.day %>
                  </div>
                  <div>
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

    socket =
      socket
      |> assign(types: types)
      |> assign(page: 1)
      |> paginate_events(page: 1, reset: true)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("next-page", _, socket) do
    {:noreply, paginate_events(socket, page: socket.assigns.page + 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_events(socket, page: 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_events(socket, page: socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  defp paginate_events(socket, options \\ []) do
    page = options[:page] || 1
    reset = options[:reset] || false

    %{instance: instance, types: types, per_page: per_page, page: cur_page} = socket.assigns

    active_types =
      types
      |> Enum.filter(fn %{active?: active?} -> active? end)
      |> Enum.map(fn %{type: type} -> type end)

    {offset, limit} =
      if page == 1 do
        {0, per_page}
      else
        {(page - 1) * per_page - 1, per_page + 1}
      end

    events =
      Instances.list_events(instance.id, types: active_types, offset: offset, limit: limit)
      |> process_events()
      |> remove_unnecessary_events(page)

    {events, at, limit} =
      if page >= cur_page do
        {events, -1, per_page * 3 * -1}
      else
        {Enum.reverse(events), 0, per_page * 3}
      end

    case events do
      [] ->
        assign(socket, end_of_timeline?: at == -1)

      [_ | _] = events ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, page)
        |> stream(:events, events, at: at, limit: limit, reset: reset)
    end
  end

  defp remove_unnecessary_events([], _), do: []
  defp remove_unnecessary_events(events, 1), do: events

  defp remove_unnecessary_events(events, _page) do
    [_ | events] = events
    events
  end

  defp process_events(events) do
    events
    |> Enum.with_index()
    |> Enum.map(fn
      {event, 0} ->
        %{id: event.id, event: event, with_day: true, with_month: true, calendar: Calendar.from_quarters(event.date)}

      {event, i} ->
        current_calendar = Calendar.from_quarters(event.date)
        prev_calendar = Calendar.from_quarters(Enum.at(events, i - 1).date)

        %{
          id: event.id,
          event: event,
          with_day: current_calendar.month.day != prev_calendar.month.day,
          with_month: current_calendar.month.number != prev_calendar.month.number,
          calendar: current_calendar
        }
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
    "before:absolute before:inset-6 md:before:inset-4 before:border before:border-4 before:border-double before:border-stone-300/80 before:z-[-1]"
  end

  defp event_icon_class() do
    "w-8 h-8 p-1.5 rounded-full border text-slate-900/70 hover:text-slate-900"
  end
end
