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
      |> assign(page_title: dgettext("app", "Administration area"))

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

    <div class="bg-white text-stone-900 max-w-screen-md mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <div class="grid grid-cols-2 gap-5">
        <.link
          navigate={~p"/#{Gettext.get_locale()}/start-a-new-adventure"}
          class="block p-5 border border-stone-200 rounded hover:bg-stone-100 transition-all"
        >
          <h2 class="font-bold text-xl pb-2">
            <%= dgettext("app", "Starting a fresh adventure") %>
          </h2>
          <p class="text-stone-900/70">
            <%= dgettext("app", "Create a new adventure with a start date and a name.") %>
          </p>
        </.link>

        <.link
          navigate={~p"/#{Gettext.get_locale()}/import-adventure"}
          class="block p-5 border border-stone-200 rounded hover:bg-stone-100 transition-all"
        >
          <h2 class="font-bold text-xl pb-2">
            <%= dgettext("app", "Import an adventure") %>
          </h2>
          <p class="text-stone-900/70">
            <%= dgettext("app", "Import an adventure from the .json export file of another adventure.") %>
          </p>
        </.link>
      </div>

      <hr />

      <h2 class="pb-3 text-xl font-bold">
        <%= dgettext("app", "List of adventures") %>
      </h2>

      <div :for={instance <- @instances} class="flex justify-between py-2 border-b">
        <span>
          <%= instance.name %>
        </span>
        <span class="flex gap-3">
          <button
            type="button"
            phx-click="reset_login"
            phx-value-id={instance.id}
            title={dgettext("app", "Resetting login details")}
            onclick={"if (!window.confirm('#{dgettext("app", "Are you sure you want to reset login details for this adventure?")}')) { event.stopPropagation(); }"}
          >
            <.icon name={:key} class="h-6 w-6 " />
          </button>
          <button
            type="button"
            phx-click="delete_instance"
            phx-value-id={instance.id}
            title={dgettext("app", "Delete adventure")}
            onclick={"if (!window.confirm('#{dgettext("app", "Are you sure you want to delete this adventure?")}')) { event.stopPropagation(); }"}
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
          |> put_flash(
            :info,
            dgettext(
              "app",
              "The login information has been reset for this adventure. The new username and password are now empty. You can connect to the adventure to set new ones."
            )
          )
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
          |> put_flash(:info, dgettext("app", "Adventure deleted."))
          |> assign(instances: Instances.get_all())

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end
end
