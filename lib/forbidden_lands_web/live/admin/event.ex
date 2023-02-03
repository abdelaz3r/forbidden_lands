defmodule ForbiddenLandsWeb.Live.Admin.Event do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_component

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.{Event, Instances}

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, changeset: Event.create(%Event{}, %{}))}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    # MAYBE ADD:
    # edition d'events

    ~H"""
    <div class="p-6">
      <section>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("admin", "Ajouter un événement") %>
        </h2>

        <.simple_form :let={f} as={:event} for={@changeset} phx-submit="create_event" phx-target={@myself}>
          <div class="grid grid-cols-2 gap-4">
            <.input
              field={{f, :human_datequarter}}
              label={dgettext("admin", "Date (dd.mm.yyyy q/4)")}
              value={Calendar.to_datequarter(@calendar)}
            />
            <.input field={{f, :type}} type="select" options={Event.types()} label={dgettext("admin", "Type")} value="normal" />
          </div>
          <.input field={{f, :title}} label={dgettext("admin", "Titre")} />
          <.input field={{f, :description}} type="textarea" label={dgettext("admin", "Description")} />
          <:actions>
            <.button color={:blue}>
              <%= dgettext("admin", "Ajouter") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section>
        <h2 class="pt-10 pb-3 text-xl font-bold">Événements</h2>

        <div :for={event <- @instance.events} class="flex justify-between py-2 border-b">
          <div>
            <div><%= event.title %></div>
            <div class="text-xs"><%= event.date |> Calendar.from_quarters() |> Calendar.format() %></div>
          </div>
          <button type="button" phx-click="delete_event" phx-value-id={event.id} phx-target={@myself}>
            <Heroicons.x_mark class="h-6 w-6 " />
          </button>
        </div>
        <p :if={length(@instance.events) == 0}>
          <%= dgettext("admin", "Aucun événements") %>
        </p>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("create_event", %{"event" => event}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    event =
      %Event{}
      |> Event.create(event)
      |> Map.put(:action, :insert)

    with true <- event.valid?,
         {:ok, _instance} = Instances.add_event(instance, event) do
      ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})

      socket =
        socket
        |> assign(:changeset, Event.create(%Event{}, %{}))
        |> put_flash(:info, "Événement créé")

      {:noreply, socket}
    else
      false -> {:noreply, assign(socket, :changeset, event)}
      {:error, _changeset} -> {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("delete_event", %{"id" => event_id}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    with event <- Enum.find(instance.events, fn event -> event.id == String.to_integer(event_id) end),
         {:ok, _instance} = Instances.remove_event(event) do
      ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
      {:noreply, put_flash(socket, :info, "Événement suppr.")}
    else
      {:error, _changeset} -> {:noreply, socket}
    end
  end
end
