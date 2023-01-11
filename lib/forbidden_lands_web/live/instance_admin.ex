defmodule ForbiddenLandsWeb.Live.InstanceAdmin do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Instances
  alias ForbiddenLands.Instances.Stronghold

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    case Instances.get(id) do
      {:ok, instance} ->
        topic = "instance-#{instance.id}"

        if connected?(socket) do
          ForbiddenLandsWeb.Endpoint.subscribe(topic)
        end

        socket =
          socket
          |> assign(page_title: instance.name)
          |> assign(topic: topic)
          |> assign(instance: instance)
          |> assign(calendar: Calendar.from_quarters(instance.current_date))
          |> assign(changeset_strongold: Stronghold.changeset(%Stronghold{}, %{}))

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
    <div class="md:p-20 min-h-screen bg-slate-700">
      <div class="flex flex-col gap-5 md:w-[700px] p-5 md:border md:border-slate-900/50 bg-slate-800 md:shadow-2xl md:shadow-black/50">
        <h1 class="text-2xl font-title">Campagne <strong><%= @instance.name %></strong></h1>

        <hr class="border-slate-900/50" />

        <section>
          <h2 class="pb-3"><%= Calendar.format(@calendar) %></h2>
          <div class="flex flex-wrap gap-2">
            <.button phx-click="move" phx-value-amount={1} style={:primary}>Prochain quarter</.button>
            <.button phx-click="move" phx-value-amount={4} style={:secondary}>Avancer d'un jour</.button>
            <.button phx-click="move" phx-value-amount={28} style={:secondary}>Avancer d'une semaine</.button>
          </div>
        </section>

        <div :if={is_nil(@instance.stronghold)}>
          <hr class="border-slate-900/50" />
          <.simple_form :let={f} as={:stronghold} for={@changeset_strongold} phx-submit="create_stronghold">
            <.input field={{f, :name}} label="Nom" />
            <.input field={{f, :coins}} type="number" label="Pièces de cuivre" />
            <:actions>
              <.button>Créer le château</.button>
            </:actions>
          </.simple_form>
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
  def handle_event("create_stronghold", %{"stronghold" => stronghold}, socket) do
    changeset = Map.put(Stronghold.changeset(%Stronghold{}, stronghold), :action, :update)

    with true <- changeset.valid?,
         {:ok, _instance} = Instances.update(socket.assigns.instance, %{"stronghold" => changeset.changes}) do
      ForbiddenLandsWeb.Endpoint.broadcast(socket.assigns.topic, "update", %{})
      {:noreply, socket}
    else
      error -> {:noreply, socket |> put_flash(:error, inspect(error)) |> assign(:changeset_strongold, changeset)}
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
