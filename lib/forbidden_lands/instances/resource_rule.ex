defmodule ForbiddenLands.Instances.ResourceRule do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Instances.ResourceRule
  alias ForbiddenLands.Instances.Stronghold

  @derive {ForbiddenLands.Export, fields: [:name, :type, :amount]}
  @type t() :: %ResourceRule{
          name: String.t() | nil,
          type: atom() | nil,
          amount: integer() | nil
        }
  embedded_schema do
    field(:name, :string)
    field(:type, Ecto.Enum, values: Stronghold.resource_fields())
    field(:amount, :integer)
  end

  @spec create(ResourceRule.t(), map()) :: Ecto.Changeset.t()
  def create(resource_rule, params \\ %{}) do
    resource_rule
    |> cast(params, [:name, :type, :amount])
    |> validate_required([:name, :type, :amount])
  end
end
