defmodule ForbiddenLands.Instances.Instance do
  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Instances.Instance
  alias ForbiddenLands.Instances.Stronghold

  @type t() :: %Instance{
          id: non_neg_integer() | nil,
          name: String.t() | nil,
          initial_date: integer() | nil,
          current_date: integer() | nil,
          stronghold: Stronghold.t() | nil
        }
  schema("instance") do
    field(:name, :string)
    field(:initial_date, :integer)
    field(:current_date, :integer)
    embeds_one(:stronghold, Stronghold)

    timestamps(type: :naive_datetime_usec)
  end

  @spec changeset(Instance.t(), map()) :: Ecto.Changeset.t()
  def changeset(instance, params \\ %{}) do
    instance
    |> cast(params, [:name, :initial_date, :current_date])
    |> validate_required([:name, :initial_date, :current_date])
    |> cast_embed(:stronghold, with: &Stronghold.changeset/2)
  end
end
