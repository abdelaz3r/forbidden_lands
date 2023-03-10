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
        <div class={["absolute w-[300px] -right-16 -top-16 h-[600px] bg-stone-200 shadow-xl rotate-3 z-10", double_border()]}></div>
        <div class={["absolute w-[300px] -left-20 top-32 h-[600px] bg-stone-200 shadow-xl -rotate-6 z-10", double_border()]}></div>
        <div class="absolute w-full -left-2 -top-3 h-[800px] bg-stone-200 shadow-xl -rotate-1 z-10"></div>
        <div class="absolute w-full left-1 -top-3 h-[600px] bg-stone-200 shadow-xl rotate-1 z-10"></div>
        <div class={["relative bg-stone-200 shadow-2xl p-5 z-20 pb-36", double_border()]}>
          <div class="text-center">
            <header class="inline-block m-auto py-[25vh]">
              <h2 class="inline-block pb-2 text-2xl text-slate-900/50">
                The full story of the
              </h2>
              <br />
              <h1 class="
                inline relative text-5xl font-bold first-letter:text-6xl text-stone-800
                after:absolute after:-right-10 after:bottom-1 after:h-[2px] after:w-[200px] after:bg-slate-600/10 after:z-[-1]
              ">
                <%= @instance.name %>
              </h1>
              <br />
              <h2 class="inline-block pt-2 text-2xl">
                And ... [subtitle]
              </h2>
            </header>
          </div>

          <div :for={{%{event: event, calendar: calendar}, i} <- Enum.with_index(@events)}>
            <div
              :if={i == 0 or Enum.at(@events, i - 1).calendar.month.number != calendar.month.number}
              class="relative text-4xl font-bold px-36 py-10"
            >
              <%= String.capitalize(calendar.month.name) %>
              <%= calendar.year.number %>
            </div>

            <section class="flex pl-20 pr-36">
              <div class="relative flex-none w-16 text-center pt-4">
                <div
                  :if={i == 0 or Enum.at(@events, i - 1).calendar.month.day != calendar.month.day}
                  class="inline-flex justify-center items-center w-12 h-12 rounded-full text-2xl text-stone-700/70 bg-stone-100/30"
                >
                  <%= calendar.month.day %>
                </div>
              </div>

              <div class="space-y-2 pb-6">
                <header>
                  <span class="relative text-xs text-stone-700/70 uppercase top-1">
                    <%= String.capitalize(calendar.quarter.name) %>
                  </span>
                  <h2 class="text-2xl font-bold">
                    <%= event.title %>
                  </h2>
                </header>

                <div :if={not is_nil(event.description)} class="text-lg space-y-2">
                  <%= Helper.text_to_raw_html(event.description) |> raw() %>
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp double_border() do
    "before:absolute before:inset-4 before:border before:border-4 before:border-double before:border-stone-300/80 before:z-[-1]"
  end
end
