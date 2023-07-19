defmodule ForbiddenLandsWeb.Live.Admin do
  @moduledoc """
  Admin view.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  alias ForbiddenLands.Instances.Instances

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    instances = Instances.get_all()

    socket =
      socket
      |> assign(instances: instances)
      |> assign(page_title: "Admin")

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <div class="bg-white text-slate-900 max-w-screen-md mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <div class="grid grid-cols-2 gap-5">
        <.link
          navigate={~p"/start-a-new-adventure"}
          class="block p-5 border border-slate-200 rounded hover:bg-slate-100 transition-all"
        >
          <h2 class="font-bold text-xl pb-2">
            Démarrer une nouvelle aventure
          </h2>
          <p class="text-slate-900/70">
            Créer une nouvelle aventure avec une date de départ et un nom.
          </p>
        </.link>

        <.link navigate={~p"/import-adventure"} class="block p-5 border border-slate-200 rounded hover:bg-slate-100 transition-all">
          <h2 class="font-bold text-xl pb-2">
            Importer une aventure
          </h2>
          <p class="text-slate-900/70">
            Importer une aventure depuis le fichier d'export d'une autre aventure.
          </p>
        </.link>
      </div>

      <hr />

      <h2 class="pb-3 text-xl font-bold">
        Liste des aventures
      </h2>

      <div :for={instance <- @instances} class="flex justify-between py-2 border-b">
        <span>
          <%= instance.name %>
        </span>
        <span class="flex gap-2">
          <button
            type="button"
            phx-click="reset_login"
            phx-value-id={instance.id}
            title="Reset login infos"
            onclick="if (!window.confirm('Reset login infos?')) { event.stopPropagation(); }"
          >
            <.icon name={:key} class="h-6 w-6 " />
          </button>
          <button
            type="button"
            phx-click="delete_instance"
            phx-value-id={instance.id}
            onclick="if (!window.confirm('Confirm delete?')) { event.stopPropagation(); }"
          >
            <.icon name={:x} class="h-6 w-6 " />
          </button>
        </span>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("reset_login", %{"id" => instance_id}, socket) do
    instance = Enum.find(socket.assigns.instances, fn instance -> instance.id == String.to_integer(instance_id) end)

    case Instances.update(instance, %{"username" => "", "password" => ""}) do
      {:ok, _instance} ->
        socket =
          socket
          |> put_flash(:info, "Information de connection réinitialisée")
          |> assign(instances: Instances.get_all())

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("delete_instance", %{"id" => instance_id}, socket) do
    instance = Enum.find(socket.assigns.instances, fn instance -> instance.id == String.to_integer(instance_id) end)

    case Instances.remove(instance) do
      {:ok, _instance} ->
        socket =
          socket
          |> put_flash(:info, "Aventure supprimée")
          |> assign(instances: Instances.get_all())

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
