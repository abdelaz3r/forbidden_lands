defmodule ForbiddenLandsWeb.Live.Dashboard do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Generic.{Image, AudioPlayer}
  import ForbiddenLandsWeb.Live.Dashboard.{Header, Stronghold, Timeline}

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

        socket =
          socket
          |> assign(page_title: instance.name)
          |> assign(quarter_shift: quarter_shift)
          |> assign(topic: topic)
          |> assign(stronghold_open?: false)
          |> base_assign(instance)

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
    <div class="md:grid md:grid-cols-[1fr_400px] h-screen bg-slate-700 overflow-hidden relative">
      <div class="hidden md:block relative overflow-hidden">
        <div class="w-full h-full overflow-hidden">
          <.image path="map.jpg" alt="Carte des Forbiddens Land" class="object-cover h-full w-full" />
        </div>
        <div class={[layer_classes(), layer_classes(@luminosity)]}></div>
      </div>

      <div class="h-screen flex flex-col bg-slate-800 border-l border-slate-900 shadow-2xl shadow-black/50">
        <.audio_player />

        <.header date={@calendar} quarter_shift={@quarter_shift} />
        <.timeline instance_id={@instance.id} events={@instance.events} />
        <.stronghold stronghold={@instance.stronghold} open?={@stronghold_open?} />
      </div>
    </div>
    """
  end

  defp layer_classes(), do: "backdrop-hue-rotate-[15deg] transition-all duration-500 absolute inset-0"
  defp layer_classes(:daylight), do: "shadow-daylight"
  defp layer_classes(:ligthish), do: "shadow-ligthish backdrop-contrast-125 bg-slate-900/20"
  defp layer_classes(:darkish), do: "shadow-darkish backdrop-contrast-125 bg-slate-900/40"
  defp layer_classes(:dark), do: "shadow-dark backdrop-contrast-200 bg-slate-900/70"

  @impl Phoenix.LiveView
  def handle_event("toggle_stronghold", _params, socket) do
    {:noreply, assign(socket, :stronghold_open?, not socket.assigns.stronghold_open?)}
  end

  @impl Phoenix.LiveView
  def handle_info(%{topic: topic, event: "toggle_stronghold"}, socket) when topic == socket.assigns.topic do
    {:noreply, assign(socket, :stronghold_open?, not socket.assigns.stronghold_open?)}
  end

  def handle_info(%{topic: topic, event: "update"}, socket) when topic == socket.assigns.topic do
    case Instances.get(socket.assigns.instance.id) do
      {:ok, instance} -> {:noreply, base_assign(socket, instance)}
      {:error, reason} -> {:noreply, put_flash(socket, :error, "Erreur générale: (#{inspect(reason)})")}
    end
  end

  defp base_assign(socket, instance) do
    calendar = Calendar.from_quarters(instance.current_date)
    luminosity = Calendar.luminosity(calendar).key

    socket
    |> assign(instance: instance)
    |> assign(calendar: calendar)
    |> assign(luminosity: luminosity)
  end
end
