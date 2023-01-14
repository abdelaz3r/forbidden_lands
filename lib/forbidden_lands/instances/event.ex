defmodule ForbiddenLands.Instances.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instance

  @types [:normal, :special]

  @type t() :: %Event{
          id: non_neg_integer() | nil,
          human_datequarter: String.t() | nil,
          date: integer() | nil,
          type: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil
        }
  schema("events") do
    field(:human_datequarter, :string, virtual: true)
    field(:date, :integer)
    field(:type, Ecto.Enum, values: @types)
    field(:title, :string)
    field(:description, :string)
    belongs_to(:instance, Instance)

    timestamps(type: :naive_datetime_usec)
  end

  @spec types() :: [atom()]
  def types() do
    @types
  end

  @spec create(Event.t(), map()) :: Ecto.Changeset.t()
  def create(event, params \\ %{}) do
    event
    |> cast(params, [:human_datequarter, :type, :title, :description])
    |> validate_required([:human_datequarter, :type, :title, :description])
    |> validate_inclusion(:type, @types)
    |> validate_length(:title, max: 200)
    |> validate_length(:description, max: 10_000)
    |> ForbiddenLands.Validation.validate_datequarter(:human_datequarter)
    |> put_date()
  end

  defp put_date(instance) do
    if not is_nil(get_change(instance, :human_datequarter)) and
         not Keyword.has_key?(instance.errors, :human_datequarter) do
      {:ok, calendar} = Calendar.from_datequarter(get_field(instance, :human_datequarter))
      put_change(instance, :date, calendar.count.quarters)
    else
      instance
    end
  end
end
