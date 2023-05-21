defmodule ForbiddenLandsWeb.Live.Manage.Event do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_component

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.{Event, Instances}

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, edit: false)}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    changeset = Map.get(socket.assigns, :changeset, default_event(assigns.calendar))

    socket =
      socket
      |> assign(instance: assigns.instance)
      |> assign(topic: assigns.topic)
      |> assign(calendar: assigns.calendar)
      |> assign(changeset: changeset)

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <section>
        <h2 class="pb-3 text-xl font-bold">
          <%= if @edit do %>
            <%= dgettext("manage", "Editer un événement") %>
          <% else %>
            <%= dgettext("manage", "Ajouter un événement") %>
          <% end %>
        </h2>

        <.simple_form :let={f} as={:event} for={@changeset} phx-submit="create_event" phx-target={@myself}>
          <div class="h-0 overflow-hidden">
            <.input :if={@edit} field={{f, :id}} type="hidden" />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <.input field={{f, :human_datequarter}} label={dgettext("manage", "Date (dd.mm.yyyy q/4)")} />
            <.input
              field={{f, :type}}
              type="select"
              options={Event.types()}
              label={dgettext("manage", "Type")}
              {if(@edit, do: %{}, else: %{value: "normal"})}
            />
          </div>
          <.input field={{f, :title}} label={dgettext("manage", "Titre")} />
          <.input field={{f, :description}} type="textarea" label={dgettext("manage", "Description")} />
          <:actions>
            <.button color={:blue}>
              <%= if @edit do %>
                <%= dgettext("manage", "Mettre à jour") %>
              <% else %>
                <%= dgettext("manage", "Ajouter") %>
              <% end %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section>
        <h2 class="pt-10 pb-3 text-xl font-bold">
          Événements (<%= length(@instance.events) %>)
        </h2>

        <div :for={event <- @instance.events} class="flex justify-between py-2 border-b">
          <div>
            <div><%= event.title %></div>
            <div class="text-xs"><%= event.date |> Calendar.from_quarters() |> Calendar.format() %></div>
          </div>
          <div class="flex gap-3">
            <button
              type="button"
              phx-click="edit_event"
              phx-value-id={event.id}
              phx-target={@myself}
              onclick="window.scrollTo(0, 0)"
            >
              <Heroicons.pencil_square class="h-6 w-6 " />
            </button>
            <button
              type="button"
              phx-click="delete_event"
              phx-value-id={event.id}
              phx-target={@myself}
              onclick="if (!window.confirm('Confirm delete?')) { event.stopPropagation(); }"
            >
              <Heroicons.x_mark class="h-6 w-6 " />
            </button>
          </div>
        </div>
        <p :if={length(@instance.events) == 0}>
          <%= dgettext("manage", "Aucun événements") %>
        </p>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "create_event",
        %{"event" => event},
        %{assigns: %{topic: topic, instance: instance, calendar: calendar, edit: false}} = socket
      ) do
    event =
      %Event{}
      |> Event.create(event)
      |> Map.put(:action, :insert)

    with true <- event.valid?,
         {:ok, _instance} = Instances.add_event(instance, event) do
      ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})

      socket =
        socket
        |> assign(:changeset, default_event(calendar))
        |> put_flash(:info, "Événement créé")

      {:noreply, socket}
    else
      false -> {:noreply, assign(socket, :changeset, event)}
      {:error, _changeset} -> {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "create_event",
        %{"event" => event},
        %{assigns: %{topic: topic, instance: instance, calendar: calendar, edit: true}} = socket
      ) do
    event =
      instance.events
      |> Enum.find(fn e -> e.id == String.to_integer(event["id"]) end)
      |> Event.create(event)
      |> Map.put(:action, :update)

    with true <- event.valid?,
         {:ok, _event} = Instances.update_event(event) do
      ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})

      socket =
        socket
        |> assign(edit: false)
        |> assign(:changeset, default_event(calendar))
        |> put_flash(:info, "Événement mis à jour")

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
      {:noreply, put_flash(socket, :info, "Événement supprimé")}
    else
      {:error, _changeset} -> {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("edit_event", %{"id" => event_id}, %{assigns: %{instance: instance}} = socket) do
    event = Enum.find(instance.events, fn event -> event.id == String.to_integer(event_id) end)
    params = %{"human_datequarter" => Calendar.from_quarters(event.date) |> Calendar.to_datequarter()}

    socket =
      socket
      |> assign(edit: true)
      |> assign(changeset: Event.create(event, params))

    {:noreply, socket}
  end

  defp default_event(calendar) do
    Event.create(%Event{}, %{"human_datequarter" => Calendar.to_datequarter(calendar)})
  end
end
