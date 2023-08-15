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
            <%= dgettext("app", "Edit an event") %>
          <% else %>
            <%= dgettext("app", "Add an event") %>
          <% end %>
        </h2>

        <.simple_form :let={f} as={:event} for={@changeset} phx-submit="create_event" phx-target={@myself}>
          <div class="h-0 overflow-hidden">
            <.input :if={@edit} field={{f, :id}} type="hidden" />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <.input field={{f, :human_datequarter}} label={dgettext("app", "Date (dd.mm.yyyy q/4)")} />
            <.input
              field={{f, :type}}
              type="select"
              options={Event.types()}
              label={dgettext("app", "Type")}
              {if(@edit, do: %{}, else: %{value: "normal"})}
            />
          </div>
          <.input field={{f, :title}} label={dgettext("app", "Title")} />
          <.input field={{f, :description}} type="textarea" label={dgettext("app", "Description")} />
          <:actions>
            <.button color={:blue}>
              <%= if @edit do %>
                <%= dgettext("app", "Edit") %>
              <% else %>
                <%= dgettext("app", "Add") %>
              <% end %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section>
        <h2 class="pt-10 pb-3 text-xl font-bold">
          <%= dgettext("app", "Events (%{events_count})", events_count: length(@instance.events)) %>
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
              title={dgettext("app", "Edit event")}
              onclick="window.scrollTo(0, 0)"
            >
              <.icon name={:pencil} class="h-5 w-5 " />
            </button>
            <button
              type="button"
              phx-click="delete_event"
              phx-value-id={event.id}
              phx-target={@myself}
              title={dgettext("app", "Delete event")}
              onclick={"if (!window.confirm('#{dgettext("app", "Are you sure you want to delete this event?")}')) { event.stopPropagation(); }"}
            >
              <.icon name={:x} class="h-5 w-5 " />
            </button>
          </div>
        </div>
        <p :if={length(@instance.events) == 0}>
          <%= dgettext("app", "No events") %>
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
        |> put_flash(:info, dgettext("app", "Event created"))

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
        |> put_flash(:info, dgettext("app", "Event updated"))

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
      {:noreply, put_flash(socket, :info, dgettext("app", "Event deleted"))}
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
