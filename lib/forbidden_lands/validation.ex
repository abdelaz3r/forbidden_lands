defmodule ForbiddenLands.Validation do
  @moduledoc false

  import Ecto.Changeset

  alias ForbiddenLands.Calendar

  @spec validate_date(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate_date(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn current_field, date ->
      case Calendar.from_date(date) do
        {:ok, _calendar} -> []
        {:error, error} -> [{current_field, "Date format error: #{error}"}]
      end
    end)
  end

  @spec validate_datequarter(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def validate_datequarter(changeset, field) when is_atom(field) do
    validate_change(changeset, field, fn current_field, datequarter ->
      case Calendar.from_datequarter(datequarter) do
        {:ok, _calendar} -> []
        {:error, error} -> [{current_field, "Date format error: #{error}"}]
      end
    end)
  end
end
