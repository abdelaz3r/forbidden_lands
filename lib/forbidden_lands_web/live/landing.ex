defmodule ForbiddenLandsWeb.Live.Landing do
  @moduledoc """
  Home view.
  List all instances.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Instances

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    instances = Instances.get_all()

    {:ok, assign(socket, page_title: "Liste des instances", instances: instances)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-white text-slate-900 max-w-[700px] mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <.link
        :for={instance <- @instances}
        navigate={~p"/adventure/#{instance.id}"}
        class="block p-5 border border-slate-200 rounded hover:bg-slate-100 transition-all min-h-[134px]"
      >
        <h2 class="font-bold text-xl pb-4"><%= instance.name %></h2>
        <p class="flex justify-between">
          <span class="opacity-40">Date de départ</span>
          <%= instance.initial_date |> Calendar.from_quarters() |> Calendar.format() %>
        </p>
        <p class="flex justify-between">
          <span class="opacity-40">Date actuelle</span>
          <%= instance.current_date |> Calendar.from_quarters() |> Calendar.format() %>
        </p>
      </.link>

      <.link
        navigate={~p"/start-a-new-adventure"}
        class="block p-5 border border-slate-200 rounded hover:bg-slate-100 transition-all min-h-[134px]"
      >
        <h2 class="font-bold text-xl pb-4">Créer une nouvelle instance</h2>
      </.link>
    </div>
    """
  end
end
