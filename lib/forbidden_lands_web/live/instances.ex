defmodule ForbiddenLandsWeb.Live.Instances do
  @moduledoc """
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
      |> assign(page_title: dgettext("app", "Forbidden Lands Companion"))

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

    <div class="bg-white text-stone-900 max-w-screen-md mx-auto md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <h2 class="font-bold text-xl">
        <%= dgettext("app", "Active adventures") %>
      </h2>

      <section :for={instance <- @instances} class="block p-5 border border-stone-200 bg-stone-100 rounded">
        <header class="space-y-5">
          <div class="space-y-2">
            <h2 class="flex items-center gap-3 font-bold text-xl">
              <.icon name={:bookmark} class="w-5 h-5" />
              <%= instance.name %>
            </h2>

            <div>
              <%= dgettext("app", "From <strong>%{start}</strong> to <strong>%{current}</strong>",
                start: instance.initial_date |> Calendar.from_quarters() |> Calendar.format(:short),
                current: instance.current_date |> Calendar.from_quarters() |> Calendar.format(:short)
              )
              |> raw() %>
            </div>
          </div>

          <p :if={instance.description}>
            <%= instance.description %>
          </p>
        </header>

        <div class="flex flex-col md:flex-row gap-2 md:gap-5 pt-5">
          <.link navigate={~p"/#{Gettext.get_locale()}/adventure/#{instance.id}"} class={["grow", button_classes()]}>
            <.icon name={:locate_fixed} class="w-6 h-6" />
            <span>
              <%= dgettext("app", "Board") %>
            </span>
          </.link>
          <.link navigate={~p"/#{Gettext.get_locale()}/adventure/#{instance.id}/story"} class={["grow", button_classes()]}>
            <.icon name={:scroll_text} class="w-6 h-6" />
            <span>
              <%= dgettext("app", "Chronicles") %>
            </span>
          </.link>
          <.link
            navigate={~p"/#{Gettext.get_locale()}/adventure/#{instance.id}/manage"}
            class={["grow md:flex-none md:w-[66px]", button_classes()]}
          >
            <.icon name={:gauge} class="w-6 h-6" />
            <span class="md:hidden">
              <%= dgettext("app", "Game master space") %>
            </span>
          </.link>
        </div>
      </section>
    </div>
    """
  end

  defp button_classes(), do: "flex gap-3 p-5 bg-white rounded border border-stone-200 hover:shadow transition-all"
end
