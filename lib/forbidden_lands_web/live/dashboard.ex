defmodule ForbiddenLandsWeb.Live.Dashboard do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Generic.Image
  import ForbiddenLandsWeb.Live.Dashboard.Header

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Stronghold
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

        socket =
          socket
          |> assign(page_title: instance.name)
          |> assign(quarter_shift: quarter_shift)
          |> assign(topic: topic)
          |> assign(instance: instance)
          |> assign(calendar: calendar)

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
          <section :for={event <- @instance.events} class="pb-4 border-b border-slate-900/50">
            <header class="pb-2">
              <.event_type_icon type={event.type} />
              <h2 class="font-bold"><%= event.title %></h2>
              <.event_date date={event.date} />
            </header>
            <div class="text-sm space-y-1.5">
              <%= Phoenix.HTML.Format.text_to_html(event.description) |> raw() %>
            </div>
          </section>
        </div>

        <div
          :if={@instance.stronghold}
          class="flex-none font-title border-t border-slate-900 shadow-2xl shadow-black/50 bg-gradient-to-l from-slate-800 to-slate-900"
        >
          <div class="p-4">
            <h1 class="flex gap-4 text-lg font-bold">
              <Heroicons.bookmark class="w-6" />
              <%= @instance.stronghold.name %>
            </h1>

            <p>Lieu: <%= @instance.stronghold.location %></p>
            <p>Def: <%= @instance.stronghold.defense %></p>
            <p>Coins: <%= inspect(Stronghold.coins_to_type(@instance.stronghold.coins)) %></p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp event_date(%{date: date} = assigns) do
    assigns = assign(assigns, calendar: Calendar.from_quarters(date))

    ~H"""
    <div class="text-sm">
      <%= @calendar.month.day %>
      <%= @calendar.month.name %>
      <span class="opacity-50">
        <%= @calendar.year.number %>,
        <span class="opacity-50">
          <%= @calendar.quarter.name %>
        </span>
      </span>
    </div>
    """
  end

  defp event_type_icon(%{type: :normal} = assigns) do
    ~H"""
    <Heroicons.bookmark class={[event_icon_class(), "bg-rose-600 border-rose-400 outline-rose-500/20"]} />
    """
  end

  defp event_type_icon(%{type: :special} = assigns) do
    ~H"""
    <Heroicons.bookmark class={[event_icon_class(), "bg-emerald-600 border-emerald-400 outline-emerald-500/20"]} />
    """
  end

  defp event_icon_class(),
    do: "float-left w-8 my-2 mr-2 p-1.5 rounded-full border outline outline-offset-2 outline-2"

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
