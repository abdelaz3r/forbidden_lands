defmodule ForbiddenLandsWeb.Live.Manage.Stronghold do
  @moduledoc """
  Stronghold panel of an instance.
  """

  use ForbiddenLandsWeb, :live_component

  alias ForbiddenLands.Instances.{Instances, ResourceRule, Stronghold}

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
          <%= dgettext("app", "Creating a stronghold") %>
        </h2>

        <.simple_form :let={f} as={:stronghold} for={@changeset_stronghold} phx-submit="update_stronghold" phx-target={@myself}>
          <.input field={{f, :name}} label={dgettext("app", "Name of the stronghold")} />
          <.input field={{f, :coins}} type="number" label={dgettext("app", "Initial copper coins")} />
          <:actions>
            <.button>
              <%= dgettext("app", "Create") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section :if={@instance.stronghold}>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("app", "Your stronghold") %>
        </h2>

        <.simple_form :let={f} as={:stronghold} for={@changeset_stronghold} phx-submit="update_stronghold" phx-target={@myself}>
          <.input field={{f, :name}} label={dgettext("app", "Name")} />
          <div class="grid grid-cols-2 gap-4">
            <.input field={{f, :defense}} type="number" label={dgettext("app", "Defence")} />
            <.input field={{f, :reputation}} type="number" label={dgettext("app", "Reputation")} />
          </div>
          <.input field={{f, :description}} type="textarea" label={dgettext("app", "Description")} style="height: 90px;" />
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input field={{f, :functions}} type="textarea" label={dgettext("app", "Functions")} style="height: 450px;" />
            <.input field={{f, :hirelings}} type="textarea" label={dgettext("app", "Hirelings & Followers")} style="height: 450px;" />
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.input field={{f, :tools}} type="textarea" label={dgettext("app", "Tools")} style="height: 115px;" />
            <.input field={{f, :items}} type="textarea" label={dgettext("app", "Treasure & Possessions")} style="height: 115px;" />
          </div>
          <div class="grid grid-cols-4 gap-4 items-end">
            <.input
              :for={resource <- Stronghold.resource_fields()}
              field={{f, resource}}
              type="number"
              label={Stronghold.resource_name(resource, 1) |> String.capitalize()}
            />
          </div>
          <:actions>
            <.button>
              <%= dgettext("app", "Save") %>
            </.button>
          </:actions>
        </.simple_form>
      </section>

      <section :if={@instance.stronghold}>
        <h2 class="pb-3 text-xl font-bold">
          <%= dgettext("app", "Rules") %>
        </h2>

        <div :for={rule <- @instance.resource_rules} class="flex justify-between py-2 border-b">
          <span :if={rule.amount > 0}>
            <%= dgettext("app", "%{rule} produce %{amount} %{resource} per week.",
              rule: rule.name,
              amount: abs(rule.amount),
              resource: Stronghold.resource_name(rule.type, abs(rule.amount))
            ) %>
          </span>
          <span :if={rule.amount < 0}>
            <%= dgettext("app", "%{rule} consume %{amount} %{resource} per week.",
              rule: rule.name,
              amount: abs(rule.amount),
              resource: Stronghold.resource_name(rule.type, abs(rule.amount))
            ) %>
          </span>
          <button
            type="button"
            phx-click="remove_rule"
            phx-value-id={rule.id}
            phx-target={@myself}
            title={dgettext("app", "Delete rule")}
          >
            <.icon name={:x} class="h-6 w-6 " />
          </button>
        </div>

        <h2 class="pb-3 text-xl font-bold pt-6">
          <%= dgettext("app", "Add a rule") %>
        </h2>

        <.simple_form :let={f} as={:rule} for={@changeset_rule} phx-submit="create_rule" phx-target={@myself}>
          <.input field={{f, :name}} label={dgettext("app", "Name")} />
          <div class="grid grid-cols-2 gap-4">
            <.input field={{f, :type}} type="select" options={resources_list()} label={dgettext("app", "Type")} />
            <.input field={{f, :amount}} type="number" label={dgettext("app", "Amount")} />
          </div>
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
  def handle_event(
        "update_stronghold",
        %{"stronghold" => stronghold},
        %{assigns: %{topic: topic, instance: instance}} = socket
      ) do
    changeset = Map.put(Stronghold.changeset(instance.stronghold || %Stronghold{}, stronghold), :action, :update)

    with true <- changeset.valid?,
         {:ok, _instance} = Instances.update(instance, %{"stronghold" => changeset.changes}) do
      ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
      {:noreply, socket}
    else
      false -> {:noreply, assign(socket, :changeset_stronghold, changeset)}
      {:error, _changeset} -> {:noreply, put_flash(socket, :error, dgettext("app", "Error."))}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("create_rule", %{"rule" => rule}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    case Instances.add_rule(instance, rule) do
      {:ok, _instance} ->
        ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset_rule, changeset)}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("remove_rule", %{"id" => id}, %{assigns: %{topic: topic, instance: instance}} = socket) do
    case Instances.remove_rule(instance, id) do
      {:ok, _instance} ->
        ForbiddenLandsWeb.Endpoint.broadcast(topic, "update", %{})
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, dgettext("app", "General error"))}
    end
  end

  defp resources_list() do
    Stronghold.resource_fields()
    |> Enum.map(fn r -> {String.capitalize(Stronghold.resource_name(r, 1)), r} end)
  end
end
