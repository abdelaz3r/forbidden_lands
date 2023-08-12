defmodule ForbiddenLands.Instances.Instances do
  @moduledoc false

  import Ecto.Query

  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instance
  alias ForbiddenLands.Repo

  @spec get(number(), number()) :: {:ok, Instance.t()} | {:error, :not_found}
  def get(id, event_limit \\ 50) do
    query =
      from(
        i in Instance,
        where: i.id == ^id,
        select: i,
        preload: [events: ^from(e in Event, order_by: [desc: e.date, desc: e.id], limit: ^event_limit)]
      )

    case Repo.one(query) do
      %Instance{} = instance -> {:ok, instance}
      nil -> {:error, :not_found}
    end
  end

  @spec get_all() :: [Instance.t()]
  def get_all() do
    query = from(i in Instance, order_by: [asc: i.id])

    Repo.all(query)
  end

  @spec list_events(number(), list()) :: [Event.t()]
  def list_events(iid, options \\ []) do
    types = options[:types] || []
    offset = options[:offset] || 0
    limit = options[:limit] || 50

    query =
      from(
        e in Event,
        where: e.instance_id == ^iid,
        where: e.type in ^types,
        order_by: [asc: e.date, asc: e.id],
        offset: ^offset,
        limit: ^limit
      )

    Repo.all(query)
  end

  @spec create(map()) :: {:ok, Instance.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    Instance.create(params)
    |> Repo.insert()
  end

  @spec create_from_export(map()) :: {:ok, Instance.t()} | {:error, Ecto.Changeset.t()}
  def create_from_export(params) do
    Instance.create_from_export(params)
    |> Repo.insert()
  end

  @spec update(Instance.t(), map(), list()) :: {:ok, Instance.t()} | {:error, Ecto.Changeset.t()}
  def update(instance, params, resource_rules \\ [])

  def update(instance, params, resource_rules) when resource_rules == [] do
    instance
    |> Instance.update(params, instance.resource_rules)
    |> Repo.update()
  end

  def update(instance, params, resource_rules) do
    instance
    |> Instance.update(params, resource_rules)
    |> Repo.update()
  end

  @spec remove(map()) :: {:ok, Instance.t()} | {:error, Ecto.Changeset.t()}
  def remove(instance) do
    Repo.delete(instance)
  end

  @spec add_event(Instance.t(), map()) :: {:ok, Instance.t()} | {:error, Ecto.Changeset.t()}
  def add_event(instance, event) do
    instance
    |> Ecto.build_assoc(:events, event)
    |> Ecto.Changeset.cast(event.changes, [:date, :type, :title, :description])
    |> Repo.insert()
  end

  @spec update_event(map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def update_event(event) do
    Repo.update(event)
  end

  @spec remove_event(map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def remove_event(event) do
    Repo.delete(event)
  end
end
