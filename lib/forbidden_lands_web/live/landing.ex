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
      <h1 class="font-bold text-xl">
        Aventures actives
      </h1>

      <section :for={instance <- @instances} class="block p-5 border border-slate-200 bg-slate-100 rounded">
        <header class="grid grid-cols-10 gap-5">
          <div class="col-span-6 flex flex-col gap-2">
            <h2 class="flex items-center gap-3 font-bold text-xl">
              <.icon name={:bookmark} class="w-5 h-5" />
              <%= instance.name %>
            </h2>
            <p :if={instance.description}>
              <%= instance.description %>
            </p>
          </div>

          <div class="col-span-4">
            <p class="flex justify-between gap-5">
              <span class="opacity-40">
                Date de départ
              </span>
              <%= instance.initial_date |> Calendar.from_quarters() |> Calendar.to_datequarter() %>
            </p>
            <p class="flex justify-between gap-5">
              <span class="opacity-40">
                Date actuelle
              </span>
              <%= instance.current_date |> Calendar.from_quarters() |> Calendar.to_datequarter() %>
            </p>
          </div>
        </header>

        <div class="flex gap-5 pt-5">
          <.link navigate={~p"/adventure/#{instance.id}"} class={["grow", button_classes()]}>
            <.icon name={:locate_fixed} class="w-6 h-6" />
            <span>Dashboard</span>
          </.link>
          <.link navigate={~p"/adventure/#{instance.id}/story"} class={["grow", button_classes()]}>
            <.icon name={:scroll_text} class="w-6 h-6" />
            <span>Chroniques</span>
          </.link>
          <.link navigate={~p"/adventure/#{instance.id}/manage"} class={["flex-none w-[66px]", button_classes()]}>
            <.icon name={:lock} class="w-6 h-6" />
          </.link>
        </div>
      </section>
    </div>
    """
  end

  defp button_classes(), do: "flex gap-3 p-5 bg-white rounded border border-slate-200 hover:shadow transition-all"
end
