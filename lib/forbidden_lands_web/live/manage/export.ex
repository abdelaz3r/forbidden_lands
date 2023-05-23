defmodule ForbiddenLandsWeb.Live.Manage.Export do
  @moduledoc """
  Export of an instance.
  """

  use ForbiddenLandsWeb, :live_component

  alias ForbiddenLands.Export

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, export?: false)}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, instance: assigns.instance)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <section>
        <div class="flex justify-between pb-3">
          <h2 class="text-xl font-bold">
            <%= dgettext("manage", "Exporter") %>
          </h2>

          <.button :if={not @export?} phx-click="export" phx-target={@myself}>
            <%= dgettext("manage", "Exporter l'instance") %>
          </.button>
          <.button
            :if={@export?}
            id="clipboard"
            data-value-success={dgettext("manage", "Copie réussie")}
            data-value-error={dgettext("manage", "Copie échouée")}
            data-to="#clipboard-target"
            phx-hook="copy-to-clipboard"
          >
            <%= dgettext("manage", "Copier dans le presse-papier") %>
          </.button>
        </div>

        <textarea :if={@export?} id="clipboard-target" class="w-full h-64" readonly={true}><%= get_export(@instance) %></textarea>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("export", _params, socket) do
    {:noreply, assign(socket, export?: true)}
  end

  defp get_export(instance) do
    instance
    |> Export.export()
    |> Jason.encode!(pretty: true)
  end
end
