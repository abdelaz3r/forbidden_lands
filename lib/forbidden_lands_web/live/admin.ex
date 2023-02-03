defmodule ForbiddenLandsWeb.Live.Admin do
  @moduledoc """
  Admin view of an instance.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Instances

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    case Instances.get(id) do
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
          |> push_navigate(to: ~p"/")
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
    <div class="bg-white text-slate-900 max-w-[700px] mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden">
      <header class="border-b">
        <nav class="flex justify-between border-b">
          <div class="flex px-3">
            <.link
              :for={%{name: name, key: key, component: _component} <- panels()}
              class={["py-4 px-3 font-bold", @panel.key == key && "text-sky-800 underline"]}
              patch={~p"/instance/#{@instance.id}/admin/#{key}"}
            >
              <span class="text-grey-600"><%= name %></span>
            </.link>
          </div>
          <div class="flex">
            <.link navigate={~p"/instance/#{@instance.id}/dashboard"} class="py-4 px-6 font-bold">
              Voir
            </.link>
          </div>
        </nav>

        <div class="py-4 px-6">
          <h1 class="text-2xl pb-2">
            Campagne <strong><%= @instance.name %></strong>
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
    case Instances.get(socket.assigns.instance.id) do
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

  defp panels() do
    [
      %{name: "Date", key: "date", component: ForbiddenLandsWeb.Live.Admin.Date},
      %{name: "Evénement", key: "event", component: ForbiddenLandsWeb.Live.Admin.Event},
      %{name: "Château", key: "stronghold", component: ForbiddenLandsWeb.Live.Admin.Stronghold}
    ]
  end
end
