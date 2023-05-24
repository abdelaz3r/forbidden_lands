defmodule ForbiddenLandsWeb.Live.Dashboard do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Generic.{Image}
  import ForbiddenLandsWeb.Live.Dashboard.{AudioPlayer, Description, Header, Stronghold, Timeline}

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
          |> assign(playlists: ForbiddenLands.Music.Mood.playlists())
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
        <h1 class="flex items-center gap-3 absolute top-4 left-3 py-1 px-2 pr-5 font-title font-bold text-xl drop-shadow-[0_0_5px_rgba(0,0,0,1)]">
          <.link navigate={~p"/"}>
            <Heroicons.chevron_left class="h-6 w-6" />
          </.link>
          <%= @instance.name %>
        </h1>
      </div>

      <div class="absolute bottom-4 left-4">
        <.audio_player playlist={@instance.mood} playlists={@playlists} />
      </div>

      <div class="h-screen relative">
        <div class="absolute inset-0 flex flex-col bg-slate-800 border-l border-slate-900 shadow-2xl shadow-black/50 z-10">
          <.header date={@calendar} quarter_shift={@quarter_shift} />
          <.timeline instance_id={@instance.id} events={@instance.events} />
          <.stronghold stronghold={@instance.stronghold} open?={@stronghold_open?} />
        </div>

        <.description :if={@instance.stronghold} stronghold={@instance.stronghold} open?={@stronghold_open?} />
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

  def handle_info(%{topic: topic, event: "update_playlist", payload: %{playlist: playlist}}, socket)
      when topic == socket.assigns.topic do
    {:noreply, assign(socket, :playlist, playlist)}
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
