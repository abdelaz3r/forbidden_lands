defmodule ForbiddenLandsWeb.Live.Manage do
  @moduledoc """
  Instance management view of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Instances
  alias ForbiddenLandsWeb.Live.Manage, as: Panel

  @events_limit 5_000

  defp panels() do
    [
      %{key: "date", icon: :bookmark, component: Panel.Date},
      %{key: "event", icon: :calendar_range, component: Panel.Event},
      %{key: "stronghold", icon: :castle, component: Panel.Stronghold},
      %{key: "export", icon: :download, component: Panel.Export},
      %{key: "settings", icon: :settings, component: Panel.Settings}
    ]
  end

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    case Instances.get(id, @events_limit) do
      {:ok, instance} ->
        topic = "instance-#{instance.id}"
        calendar = Calendar.from_quarters(instance.current_date)

        if connected?(socket) do
          ForbiddenLandsWeb.Endpoint.subscribe(topic)
        end

        socket =
          socket
          |> assign(page_title: instance.name)
          |> assign(topic: topic)
          |> assign(instance: instance)
          |> assign(calendar: calendar)

        {:ok, socket}

      {:error, _reason} ->
        socket =
          socket
          |> push_navigate(to: ~p"/#{Gettext.get_locale()}/")
          |> put_flash(:error, "Cette instance n'existe pas")

        {:ok, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    panel_name = Map.get(params, "panel")
    panel = Enum.find(panels(), List.first(panels()), fn %{key: key} -> key == panel_name end)
    socket = assign(socket, :panel, panel)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <div class="bg-white text-slate-900 max-w-screen-md mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden">
      <header class="border-b">
        <nav class="flex justify-between border-b">
          <div class="flex px-3">
            <.link
              :for={%{key: key, icon: icon, component: _component} <- panels()}
              class={["py-4 px-3 font-bold", @panel.key == key && "text-sky-800 underline"]}
              patch={~p"/#{Gettext.get_locale()}/adventure/#{@instance.id}/manage/#{key}"}
            >
              <span class="text-grey-600">
                <.icon name={icon} class="w-6 h-6" />
              </span>
            </.link>
          </div>
          <div class="flex">
            <.link navigate={~p"/#{Gettext.get_locale()}/adventure/#{@instance.id}"} class="py-4 px-6 font-bold">
              <.icon name={:corner_right_up} class="w-6 h-6" />
            </.link>
          </div>
        </nav>

        <div class="py-4 px-6">
          <h1 class="flex flex-col md:flex-row md:gap-2 text-2xl pb-2">
            <span>Campagne</span>
            <strong><%= @instance.name %></strong>
          </h1>
          <h2>
            <%= Calendar.format(@calendar) %>
          </h2>
        </div>
      </header>

      <div>
        <.live_component
          module={@panel.component}
          id={"panel-#{@panel.key}"}
          topic={@topic}
          instance={@instance}
          calendar={@calendar}
        />
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_info(%{topic: topic, event: "update"}, socket) when topic == socket.assigns.topic do
    case Instances.get(socket.assigns.instance.id, @events_limit) do
      {:ok, instance} ->
        calendar = Calendar.from_quarters(instance.current_date)

        socket =
          socket
          |> assign(instance: instance)
          |> assign(calendar: calendar)

        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Erreur générale: (#{inspect(reason)})")}
    end
  end

  def handle_info(%{topic: topic, event: _event}, socket) when topic == socket.assigns.topic do
    {:noreply, socket}
  end
end
