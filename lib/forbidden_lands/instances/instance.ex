defmodule ForbiddenLands.Instances.Instance do
  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Instances.Instance

  @type t() :: %Instance{
          id: non_neg_integer() | nil,
          name: String.t() | nil,
          initial_date: integer() | nil,
          current_date: integer() | nil
        }
  schema("instance") do
    field(:name, :string)
    field(:initial_date, :integer)
    field(:current_date, :integer)
  end

  @spec changeset(Instance.t(), map()) :: Ecto.Changeset.t()
  def changeset(instance, params \\ %{}) do
    instance
    |> cast(params, [:name, :initial_date, :current_date])
    |> validate_required([:name, :initial_date, :current_date])
  end
end
