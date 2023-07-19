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
    <div class="flex flex-col gap-6 p-6">
      <section>
        <.simple_form :let={f} as={:instance} for={@changeset} phx-submit="update" phx-target={@myself}>
          <h2 class="pb-3 text-xl font-bold">
            <%= dgettext("manage", "Paramètres de l'instance") %>
          </h2>

          <.input field={{f, :name}} label={dgettext("manage", "Nom de l'instance")} />
          <.input field={{f, :description}} label={dgettext("manage", "Description")} type="textarea" style="height: 120px;" />

          <hr class="my-5" />

          <h2 class="pb-3 text-xl font-bold">
            <%= dgettext("manage", "Affichage des chroniques") %>
          </h2>

          <.input field={{f, :prepend_name}} label={dgettext("manage", "Sur-titre du nom")} />
          <.input field={{f, :append_name}} label={dgettext("manage", "Sous-titre du nom")} />

          <p class="text-xs">
            <%= dgettext("manage", "Exemple :") %>
          </p>
          <aside class="font-title text-center px-4 py-6 border bg-slate-100/50 mb-5">
            <h2 :if={@instance.prepend_name} class="inline-block pb-2 text-2xl text-slate-900/50">
              <%= @instance.prepend_name %>
            </h2>
            <br />
            <h1 class="inline relative text-5xl font-bold first-letter:text-6xl text-stone-800">
              <%= @instance.name %>
            </h1>
            <br />
            <h2 :if={@instance.append_name} class="inline-block pt-3 text-2xl">
              <%= @instance.append_name %>
            </h2>
          </aside>

          <.input field={{f, :introduction}} label={dgettext("manage", "Introduction")} type="textarea" style="height: 120px;" />

          <:actions>
            <.button>
              <%= dgettext("manage", "Enregistrer") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section>
        <.simple_form :let={f} as={:instance} for={@changeset} phx-submit="update" phx-target={@myself}>
          <h2 class="pb-3 text-xl font-bold">
            <%= dgettext("manage", "Paramètres de login") %>
          </h2>

          <.input field={{f, :username}} label={dgettext("manage", "Nom d'utilisateur")} />
          <.input field={{f, :password}} label={dgettext("manage", "Nouveau mot de passe")} />

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
