defmodule ForbiddenLands.Instances.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Event
  alias ForbiddenLands.Instances.Instance

  @types [:automatic, :normal, :special, :legendary, :death]
  @title_max_length 200
  @description_max_length 10_000

  @derive {ForbiddenLands.Export, fields: [:date, :type, :title, :description]}
  @type t() :: %Event{
          id: non_neg_integer() | nil,
          human_datequarter: String.t() | nil,
          date: integer() | nil,
          type: atom() | nil,
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
    |> validate_required([:human_datequarter, :type, :title])
    |> validate_inclusion(:type, @types)
    |> validate_length(:title, max: @title_max_length)
    |> validate_length(:description, max: @description_max_length)
    |> ForbiddenLands.Validation.validate_datequarter(:human_datequarter)
    |> put_date()
  end

  @spec create_from_export(Event.t(), map()) :: Ecto.Changeset.t()
  def create_from_export(event, params \\ %{}) do
    event
    |> cast(params, [:date, :type, :title, :description])
    |> validate_required([:date, :type, :title])
    |> validate_inclusion(:type, @types)
    |> validate_length(:title, max: @title_max_length)
    |> validate_length(:description, max: @description_max_length)
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

  @spec icon_by_type(atom()) :: atom()
  def icon_by_type(:automatic), do: :minus
  def icon_by_type(:normal), do: :list_minus
  def icon_by_type(:special), do: :sparkle
  def icon_by_type(:legendary), do: :sparkles
  def icon_by_type(:death), do: :swords
  def icon_by_type(_type), do: :dot
end
