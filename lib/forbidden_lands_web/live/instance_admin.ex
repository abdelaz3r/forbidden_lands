defmodule ForbiddenLandsWeb.Live.InstanceAdmin do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Generic.Button

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

        socket =
          socket
          |> assign(page_title: instance.name)
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
      <div class="h-screen flex flex-col overflow-hidden bg-slate-800 border-l border-slate-900 shadow-2xl shadow-black/50">
        <div class="p-4 text-slate-100">
          <%= Calendar.format(@calendar) %>
        </div>

        <div class="grow overflow-y-auto flex flex-col gap-4 p-4 font-title text-slate-100">
          <div class="flex flex-wrap gap-2">
            <.button :for={amount <- [1, 4, 28, 180, 1460, -1, -4]} phx-click="move" phx-value-amount={amount} style={:secondary}>
              <%= amount %> Quarters
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("move", %{"amount" => amount}, socket) do
    # Par la suite:
    # - si on passe une semaine
    #   - charge les données de mise à jour auto
    #   - update les infos du château
    #    - crée l'event automatique

    new_quarters = socket.assigns.instance.current_date + String.to_integer(amount)

    case Instances.update(socket.assigns.instance, %{current_date: new_quarters}) do
      {:ok, _instance} ->
        ForbiddenLandsWeb.Endpoint.broadcast(socket.assigns.topic, "update", %{})
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Erreur dans la mise à jour: (#{inspect(reason)})")}
    end
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
