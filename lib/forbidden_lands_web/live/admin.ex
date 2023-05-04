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
      <.link
        navigate={~p"/start-a-new-adventure"}
        class="block p-5 border border-slate-200 rounded hover:bg-slate-100 transition-all"
      >
        <h2 class="font-bold text-xl pb-4">
          Démarrer une nouvelle aventure
        </h2>
      </.link>

      <hr />

      <h2 class="pb-3 text-xl font-bold">
        Liste des aventures
      </h2>

      <div :for={instance <- @instances} class="flex justify-between py-2 border-b">
        <span>
          <%= instance.name %>
        </span>
        <!--
        <button type="button" phx-click="remove_rule">
          <Heroicons.x_mark class="h-6 w-6 " />
        </button>
        -->
      </div>
    </div>
    """
  end
end
