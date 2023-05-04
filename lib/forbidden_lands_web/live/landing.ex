defmodule ForbiddenLandsWeb.Live.Landing do
  @moduledoc """
  Home view.
  List all instances.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Instances

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    instances = Instances.get_all()

    socket =
      socket
      |> assign(instances: instances)
      |> assign(page_title: "Liste des instances")

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
      <section :for={instance <- @instances} class="block p-5 border border-slate-200 rounded min-h-[134px]">
        <header class="grid grid-cols-2">
          <h2 class="font-bold text-xl pb-4">
            <%= instance.name %>
          </h2>
          <div>
            <p class="flex justify-between">
              <span class="opacity-40">
                Date de départ
              </span>
              <%= instance.initial_date |> Calendar.from_quarters() |> Calendar.format() %>
            </p>
            <p class="flex justify-between">
              <span class="opacity-40">
                Date actuelle
              </span>
              <%= instance.current_date |> Calendar.from_quarters() |> Calendar.format() %>
            </p>
          </div>
        </header>

        <div class="grid grid-cols-3 gap-5 pt-5">
          <.link navigate={~p"/adventure/#{instance.id}"} class="p-5 bg-slate-100">
            Dashboard
          </.link>
          <.link navigate={~p"/adventure/#{instance.id}/story"} class="p-5 bg-slate-100">
            Story
          </.link>
          <.link navigate={~p"/adventure/#{instance.id}/manage"} class="p-5 bg-slate-100">
            Manage
          </.link>
        </div>
      </section>
    </div>
    """
  end
end
