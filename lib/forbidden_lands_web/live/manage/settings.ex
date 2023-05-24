defmodule ForbiddenLandsWeb.Live.Manage.Settings do
  @moduledoc """
  Settings of an instance.
  """

  use ForbiddenLandsWeb, :live_component

  alias ForbiddenLands.Instances.{Instance, Instances}

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket =
      socket
      |> assign(instance: assigns.instance)
      |> assign(topic: assigns.topic)
      |> assign(changeset: Instance.update(assigns.instance, %{}))

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <section>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("manage", "Paramètres") %>
        </h2>

        <.simple_form :let={f} as={:instance} for={@changeset} phx-submit="update" phx-target={@myself}>
          <.input field={{f, :name}} label={dgettext("manage", "Nom de l'instance")} />
          <:actions>
            <.button>
              <%= dgettext("manage", "Enregistrer") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("update", %{"instance" => params}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    case Instances.update(instance, params) do
      {:ok, _instance} ->
        ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Error: (#{inspect(reason)})")}
    end
  end
end
