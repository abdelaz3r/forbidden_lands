defmodule ForbiddenLandsWeb.Live.Dashboard do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Generic.Image
  import ForbiddenLandsWeb.Live.Dashboard.Header

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Instances

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    case Instances.get(id) do
      {:ok, instance} ->
        topic = "instance-#{instance.id}"

        if connected?(socket) do
          ForbiddenLandsWeb.Endpoint.subscribe(topic)
        end

        calendar = Calendar.from_quarters(instance.current_date)
        quarter_shift = calendar.count.quarters - rem(calendar.count.quarters - 1, 4)
        messages = Enum.map(1..20, fn i -> Calendar.add(calendar, i * 32 + Enum.random(0..3), :quarter) end)

        socket =
          socket
          |> assign(page_title: instance.name)
          |> assign(quarter_shift: quarter_shift)
          |> assign(topic: topic)
          |> assign(instance: instance)
          |> assign(calendar: calendar)
          |> assign(messages: messages)

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
    <div class="md:grid md:grid-cols-[1fr_400px] h-screen bg-slate-700">
      <div class="hidden md:block relative overflow-hidden">
        <div class="w-full h-full overflow-hidden">
          <.image path="map.jpg" alt="Carte des Forbiddens Land" class="object-cover h-full w-full" />
        </div>
      </div>

      <div class="h-screen flex flex-col overflow-hidden bg-slate-800 border-l border-slate-900 shadow-2xl shadow-black/50">
        <.header
          date={@calendar}
          quarter_shift={@quarter_shift}
          class="flex-none z-10 border-b border-slate-900 shadow-2xl shadow-black/50"
        />

        <div class="grow overflow-y-auto flex flex-col gap-4 p-4 font-title">
          <section :for={message <- @messages} class="pb-4 border-b border-slate-900/50">
            <header class="flex justify-between">
              <h2 class="font-bold">
                Title
              </h2>
              <div>
                <%= message.month.day %>
                <%= message.month.name %>
                <span class="opacity-50">
                  <%= message.year.number %>,
                  <span class="opacity-50">
                    <%= message.quarter.name %>
                  </span>
                </span>
              </div>
            </header>
            <p class="text-sm">Un événement au bol...</p>
          </section>
        </div>

        <div
          :if={@instance.stronghold}
          class="flex-none font-title border-t border-slate-900 shadow-2xl shadow-black/50 bg-gradient-to-l from-slate-800 to-slate-900"
        >
          <div class="p-4">
            <h1 class="flex gap-4 text-lg font-bold">
              <Heroicons.bookmark class="w-6" /> Weatherstone
            </h1>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_info(%{topic: topic, event: "update"}, socket) when topic == socket.assigns.topic do
    case Instances.get(socket.assigns.instance.id) do
      {:ok, instance} ->
        calendar = Calendar.from_quarters(instance.current_date)

        socket =
          socket
          |> assign(instance: instance)
          |> assign(calendar: calendar)

        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Erreur générale: (#{inspect(reason)})")}
    end
  end
end
