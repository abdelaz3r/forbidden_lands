defmodule ForbiddenLands.Instances.Instances do
  # import Ecto.Query

  alias ForbiddenLands.Instances.Instance
  alias ForbiddenLands.Repo

  @spec get(number()) :: {:ok, Instance.t()} | {:error, :not_found}
  def get(id) do
    case Repo.get(Instance, id) do
      %Instance{} = instance -> {:ok, instance}
      nil -> {:error, :not_found}
    end
  end

  @spec get_all() :: [Instance.t()]
  def get_all() do
    Repo.all(Instance)
  end

  @spec create(map()) :: {:ok, Instance.t()} | {:error, Changeset.t()}
  def create(params) do
    %Instance{}
    |> Instance.changeset(params)
    |> Repo.insert()
  end

  @spec update(Instance.t(), map()) :: {:ok, Instance.t()} | {:error, Changeset.t()}
  def update(instance, params) do
    instance
    |> Instance.changeset(params)
    |> Repo.update()
  end
end
