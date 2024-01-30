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
            <%= dgettext("app", "Export") %>
          </h2>

          <.button :if={not @export?} phx-click="export" phx-target={@myself}>
            <%= dgettext("app", "Export the adventure") %>
          </.button>
          <.button
            :if={@export?}
            id="clipboard"
            data-value-success={dgettext("app", "Successful copy")}
            data-value-error={dgettext("app", "Copy failed")}
            data-to="#clipboard-target"
            phx-hook="copy-to-clipboard"
          >
            <%= dgettext("app", "Copy to clipboard") %>
          </.button>
        </div>

        <textarea
          :if={@export?}
          id="clipboard-target"
          class={[
            "h-64 w-full rounded border-2 p-2",
            "text-stone-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
            "border-sky-500 focus:ring-sky-500/20"
          ]}
          readonly={true}
        ><%= get_export(@instance) %></textarea>
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
