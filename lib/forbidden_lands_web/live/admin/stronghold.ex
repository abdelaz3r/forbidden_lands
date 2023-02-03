defmodule ForbiddenLandsWeb.Live.Admin.Stronghold do
  @moduledoc """
  Dashboard of an instance.
  """

  use ForbiddenLandsWeb, :live_component

  alias ForbiddenLands.Instances.{Instances, Stronghold, ResourceRule}

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    stronghold = assigns.instance.stronghold || %Stronghold{}

    socket =
      socket
      |> assign(instance: assigns.instance)
      |> assign(topic: assigns.topic)
      |> assign(changeset_stronghold: Stronghold.changeset(stronghold, %{}))
      |> assign(changeset_rule: ResourceRule.create(%ResourceRule{}, %{}))

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="p-6 flex flex-col gap-10">
      <section :if={is_nil(@instance.stronghold)}>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("admin", "Créer un château") %>
        </h2>

        <.simple_form :let={f} as={:stronghold} for={@changeset_stronghold} phx-submit="update_stronghold" phx-target={@myself}>
          <.input field={{f, :name}} label={dgettext("admin", "Nom du château")} />
          <.input field={{f, :coins}} type="number" label={dgettext("admin", "Pièces de cuivre initiales")} />
          <:actions>
            <.button>
              <%= dgettext("admin", "Créer") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section :if={@instance.stronghold}>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("admin", "Votre château") %>
        </h2>

        <.simple_form :let={f} as={:stronghold} for={@changeset_stronghold} phx-submit="update_stronghold" phx-target={@myself}>
          <.input field={{f, :name}} label={dgettext("admin", "Nom")} />
          <div class="grid grid-cols-2 gap-4">
            <.input field={{f, :defense}} type="number" label={dgettext("admin", "Défense")} />
            <.input field={{f, :reputation}} type="number" label={dgettext("admin", "Réputation")} />
          </div>
          <.input field={{f, :description}} type="textarea" label={dgettext("admin", "Description")} />
          <.input field={{f, :functions}} type="textarea" label={dgettext("admin", "Bâtiments")} />
          <.input field={{f, :hirelings}} type="textarea" label={dgettext("admin", "Employés")} />
          <div class="grid grid-cols-3 gap-4">
            <.input
              :for={resource <- Stronghold.resource_fields()}
              field={{f, resource}}
              type="number"
              label={Stronghold.resource_name(resource, 1)}
            />
          </div>
          <:actions>
            <.button>
              <%= dgettext("admin", "Enregistrer") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section :if={@instance.stronghold}>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("admin", "Règles") %>
        </h2>

        <div :for={rule <- @instance.resource_rules} class="flex justify-between py-2 border-b">
          <span :if={rule.amount > 0}>
            <%= rule.name %> produit <%= abs(rule.amount) %> <%= Stronghold.resource_name(rule.type, rule.amount) %> par semaine.
          </span>
          <span :if={rule.amount < 0}>
            <%= rule.name %> consomme <%= abs(rule.amount) %> <%= Stronghold.resource_name(rule.type, rule.amount) %> par semaine
          </span>
          <button type="button" phx-click="remove_rule" phx-value-id={rule.id} phx-target={@myself}>
            <Heroicons.x_mark class="h-6 w-6 " />
          </button>
        </div>

        <h2 class="pb-3 text-xl font-bold pt-6">
          <%= dgettext("admin", "Ajouter une règle") %>
        </h2>

        <.simple_form :let={f} as={:rule} for={@changeset_rule} phx-submit="create_rule" phx-target={@myself}>
          <.input field={{f, :name}} label="Nom" />
          <div class="grid grid-cols-2 gap-4">
            <.input field={{f, :type}} type="select" options={Stronghold.resource_fields()} label="Type" />
            <.input field={{f, :amount}} type="number" label="Quantité" />
          </div>
          <:actions>
            <.button>Créer</.button>
          </:actions>
        </.simple_form>
      </section>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "update_stronghold",
        %{"stronghold" => stronghold},
        %{assigns: %{topic: topic, instance: instance}} = socket
      ) do
    IO.inspect(stronghold)
    changeset = Map.put(Stronghold.changeset(instance.stronghold || %Stronghold{}, stronghold), :action, :update)

    with true <- changeset.valid?,
         {:ok, _instance} = Instances.update(instance, %{"stronghold" => changeset.changes}) do
      ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
      {:noreply, socket}
    else
      false -> {:noreply, assign(socket, :changeset_stronghold, changeset)}
      {:error, _changeset} -> {:noreply, put_flash(socket, :error, "error")}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("create_rule", %{"rule" => rule}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    changeset = Map.put(ResourceRule.create(%ResourceRule{}, rule), :action, :update)

    with true <- changeset.valid?,
         {:ok, _instance} = Instances.update(instance, %{}, instance.resource_rules ++ [changeset.changes]) do
      ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
      {:noreply, socket}
    else
      false ->
        {:noreply, assign(socket, :changeset_rule, changeset)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "error")}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("remove_rule", %{"id" => id}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    resource_rules = Enum.filter(instance.resource_rules, fn rule -> rule.id != id end)

    case Instances.update(instance, %{}, resource_rules) do
      {:ok, _instance} ->
        ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Erreur dans la mise à jour: (#{inspect(reason)})")}
    end
  end
end
