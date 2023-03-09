defmodule ForbiddenLandsWeb.Live.Story do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Instances.Instances
  alias ForbiddenLands.Calendar

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    case Instances.get(id) do
      {:ok, instance} ->
        events =
          instance.events
          |> Enum.reverse()
          |> Enum.map(fn event ->
            %{event: event, calendar: Calendar.from_quarters(event.date)}
          end)

        socket =
          socket
          |> assign(page_title: instance.name)
          |> assign(instance: instance)
          |> assign(events: events)

        {:ok, socket}

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
    <div class="text-slate-900 font-title py-[40vh] bg-fixed bg-center bg-no-repeat bg-cover bg-[url('/images/story-background.jpg')]">
      <div class="relative w-[800px] mx-auto">
        <div class="absolute w-full -left-2 -top-3 h-[800px] bg-stone-100 shadow-xl -rotate-1 z-10"></div>
        <div class="absolute w-full left-1 -top-3 h-[600px] bg-stone-100 shadow-xl rotate-1 z-10"></div>
        <div class="relative bg-stone-100 shadow-2xl p-5 z-20 before:absolute before:inset-4 before:border before:border-4 before:border-double before:border-stone-200/80 before:z-[-1]">
          <header class="p-5 pl-6 pb-32">
            <h1 class="relative text-4xl font-bold first-letter:text-5xl before:absolute before:-left-3 before:-top-2 before:-bottom-2 before:w-16 before:bg-lime-600/40 before:border before:border-lime-600/40 before:z-[-1]">
              <%= @instance.name %>
            </h1>
            <h2 class="pt-3 text-2xl">
              A comprehensive story...
            </h2>
          </header>

          <div>
            <div :for={{%{event: event, calendar: calendar}, i} <- Enum.with_index(@events)}>
              <div
                :if={i == 0 or Enum.at(@events, i - 1).calendar.month.number != calendar.month.number}
                class="text-4xl text-center py-16"
              >
                <%= String.capitalize(calendar.month.name) %>
                <%= calendar.year.number %>
              </div>

              <section class="flex pl-20 pr-36">
                <div class="relative flex-none w-16 text-center pt-4 before:absolute before:top-0 before:bottom-0 before:left-8 before:w-[1px] before:bg-amber-500/20 before:z-[-1]">
                  <div
                    :if={i == 0 or Enum.at(@events, i - 1).calendar.month.day != calendar.month.day}
                    class="inline-flex justify-center items-center w-12 h-12 rounded-full text-2xl bg-stone-100 border border-amber-500 outline outline-offset-[1px] outline-1 outline-amber-500/20"
                  >
                    <%= calendar.month.day %>
                  </div>
                </div>

                <div class="space-y-2 pb-6">
                  <header>
                    <span class="text-xs text-slate-900/60 uppercase">
                      <%= String.capitalize(calendar.quarter.name) %>
                    </span>
                    <h2 class="text-2xl font-bold">
                      <%= event.title %>
                    </h2>
                  </header>

                  <div :if={not is_nil(event.description)} class="space-y-2">
                    <%= Helper.text_to_raw_html(event.description) |> raw() %>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
