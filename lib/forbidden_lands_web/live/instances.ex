defmodule ForbiddenLandsWeb.Live.Instances do
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

    {:ok, assign(socket, instances: instances)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="p-5 md:p-20 min-h-screen bg-slate-700 text-slate-100 font-title">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        <.link
          :for={instance <- @instances}
          navigate={~p"/instance/#{instance.id}"}
          class="block p-5 min-h-[134px] border border-slate-900/50 bg-slate-800 shadow-2xl shadow-black/50"
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
          navigate={~p"/new"}
          class="block p-5 min-h-[134px] border border-slate-900/50 bg-slate-800 shadow-2xl shadow-black/50"
        >
          <h2 class="font-bold text-xl pb-4">Créer une nouvelle instance</h2>
        </.link>
      </div>
    </div>
    """
  end
end
