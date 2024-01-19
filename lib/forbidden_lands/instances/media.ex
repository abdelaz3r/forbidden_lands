defmodule ForbiddenLands.Instances.Media do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Instances.Media

  @derive {ForbiddenLands.Export, fields: [:name, :url]}
  @type t() :: %Media{
          name: String.t() | nil,
          url: String.t() | nil
        }
  embedded_schema do
    field(:name, :string)
    field(:url, :string)
  end

  @spec create(Media.t()) :: Ecto.Changeset.t()
  @spec create(Media.t(), map()) :: Ecto.Changeset.t()
  def create(resource_rule, params \\ %{}) do
    resource_rule
    |> cast(params, [:name, :url])
    |> validate_required([:name, :url])
  end
end
