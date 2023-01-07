defmodule ForbiddenLandsWeb.Live.Dashboard do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Generic.Button
  import ForbiddenLandsWeb.Components.Generic.Image
  import ForbiddenLandsWeb.Live.Dashboard.Header

  alias ForbiddenLands.Calendar

  @current_quarter 1_701_993
  @topic "main"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      ForbiddenLandsWeb.Endpoint.subscribe(@topic)
    end

    now = Calendar.from_quarters(@current_quarter)
    quarter_shift = now.count.quarters - rem(now.count.quarters - 1, 4)
    messages = Enum.map(1..20, fn i -> Calendar.add(now, i * 32 + Enum.random(0..3), :quarter) end)

    socket =
      socket
      |> assign(now: now)
      |> assign(quarter_shift: quarter_shift)
      |> assign(messages: messages)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
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
          date={@now}
          quarter_shift={@quarter_shift}
          class="flex-none z-10 border-b border-slate-900 shadow-2xl shadow-black/50"
        />

        <div class="grow overflow-y-auto flex flex-col gap-4 p-4 font-title text-slate-100">
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

          <div class="flex flex-wrap gap-2">
            <.button
              :for={amount <- [1, 4, 28, 180, 1460, -1, -4, -28, -180, -1460]}
              phx-click="move"
              phx-value-amount={amount}
              phx-value-type="quarter"
              style={:secondary}
            >
              <%= amount %> Quarter
            </.button>
          </div>
        </div>

        <div class="flex-none h-40 font-title text-slate-100 border-t border-slate-900 shadow-2xl shadow-black/50 bg-gradient-to-l from-slate-800 to-slate-900">
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
  def handle_event("move", %{"amount" => amount, "type" => type}, socket) do
    # Par la suite:
    # - l'event deviendra "next", "amount" (quarter)
    # - appel le calendrier et fait la maj.
    # - récupère le nouveau nombre de quarter
    # - update la date en bdd
    # - si on passe une semaine
    #   - charge les données de mise à jour auto
    #   - update les infos du château
    #    - crée l'event automatique
    # - envoie `now`, `events` (si changement), et `castle` (si changement)

    now = Calendar.add(socket.assigns.now, String.to_integer(amount), String.to_existing_atom(type))
    ForbiddenLandsWeb.Endpoint.broadcast(@topic, "update", %{now: now})

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(%{topic: @topic, event: "update", payload: %{now: now}}, socket) do
    {:noreply, assign(socket, now: now)}
  end
end
