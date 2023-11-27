defmodule ForbiddenLandsWeb.Live.Manage.Media do
  @moduledoc """
  Media panel of an instance.
  """

  use ForbiddenLandsWeb, :live_component

  alias ForbiddenLands.Instances.{Instances, Media}

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket =
      socket
      |> assign(instance: assigns.instance)
      |> assign(topic: assigns.topic)
      |> assign(changeset_media: Media.create(%Media{}, %{}))

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="p-6 flex flex-col gap-10">
      <section>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("app", "Medias for overlay") %>
        </h2>

        <div :for={media <- @instance.medias} class="flex justify-between py-2 border-b">
          <span>
            <strong>
              <%= media.name %>
            </strong>
            (<a href={media.url} target="_blank" class="underline"><%= media.url %></a>)
          </span>
          <button
            type="button"
            phx-click="remove_media"
            phx-value-id={media.id}
            phx-target={@myself}
            title={dgettext("app", "Delete media")}
          >
            <.icon name={:x} class="h-6 w-6 " />
          </button>
        </div>

        <h2 class="pb-3 text-xl font-bold pt-6">
          <%= dgettext("app", "Add a media") %>
        </h2>

        <.simple_form :let={f} as={:media} for={@changeset_media} phx-submit="create_media" phx-target={@myself}>
          <.input field={{f, :name}} label={dgettext("app", "Name")} />
          <.input field={{f, :url}} label={dgettext("app", "Url (valid link to an image)")} />
          <:actions>
            <.button>
              <%= dgettext("app", "Create") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("create_media", %{"media" => media}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    case Instances.add_media(instance, media) do
      {:ok, _instance} ->
        ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset_media, changeset)}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("remove_media", %{"id" => id}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    case Instances.remove_media(instance, id) do
      {:ok, _instance} ->
        ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, dgettext("app", "General error"))}
    end
  end
end
