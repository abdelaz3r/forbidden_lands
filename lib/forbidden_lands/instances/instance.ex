defmodule ForbiddenLands.Instances.Instance do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instance
  alias ForbiddenLands.Instances.ResourceRule
  alias ForbiddenLands.Instances.Stronghold

  @type t() :: %Instance{
          id: non_neg_integer() | nil,
          name: String.t() | nil,
          human_date: String.t() | nil,
          initial_date: integer() | nil,
          current_date: integer() | nil,
          mood: String.t() | nil,
          stronghold: Stronghold.t() | nil
        }
  schema("instances") do
    field(:name, :string)
    field(:human_date, :string, virtual: true)
    field(:initial_date, :integer)
    field(:current_date, :integer)
    field(:mood, :string)
    embeds_one(:stronghold, Stronghold, on_replace: :update)
    embeds_many(:resource_rules, ResourceRule, on_replace: :delete)
    has_many(:events, Event)

    timestamps(type: :naive_datetime_usec)
  end

  @spec create(Instance.t(), map()) :: Ecto.Changeset.t()
  def create(instance, params \\ %{}) do
    instance
    |> cast(params, [:name, :human_date])
    |> validate_required([:name, :human_date])
    |> ForbiddenLands.Validation.validate_date(:human_date)
    |> put_dates()
  end

  @spec update(Instance.t(), map(), list()) :: Ecto.Changeset.t()
  def update(instance, params \\ %{}, resource_rules \\ []) do
    instance
    |> cast(params, [:name, :current_date, :mood])
    |> validate_required([:name, :current_date, :mood])
    |> cast_embed(:stronghold, with: &Stronghold.changeset/2)
    |> put_embed(:resource_rules, resource_rules)
  end

  defp put_dates(instance) do
    if not is_nil(get_change(instance, :human_date)) and not Keyword.has_key?(instance.errors, :human_date) do
      {:ok, calendar} = Calendar.from_date(get_field(instance, :human_date))

      instance
      |> put_change(:initial_date, calendar.count.quarters)
      |> put_change(:current_date, calendar.count.quarters)
    else
      instance
    end
  end
end
