defmodule ForbiddenLands.Tools.Dice do
  @moduledoc false

  import ForbiddenLandsWeb.Gettext

  alias ForbiddenLands.Tools.Dice

  @types [
    %{key: :base, base: 6, name: dgettext("dice", "Base"), max: 12},
    %{key: :skill, base: 6, name: dgettext("dice", "Skill"), max: 12},
    %{key: :gear, base: 6, name: dgettext("dice", "Gear"), max: 12},
    %{key: :artifact_8, base: 8, name: dgettext("dice", "Artifact 8"), max: 12},
    %{key: :artifact_10, base: 10, name: dgettext("dice", "Artifact 10"), max: 12},
    %{key: :artifact_12, base: 12, name: dgettext("dice", "Artifact 12"), max: 12}
  ]

  @type t() :: %Dice{
          key: atom(),
          base: integer(),
          roll: integer() | nil,
          state: :not_rolled | :rolled | :pushed
        }
  defstruct [:key, :base, :roll, :state]

  @spec new(atom()) :: Dice.t()
  def new(type) do
    data = data_type(type)

    %Dice{
      key: type,
      base: data.base,
      roll: nil,
      state: :not_rolled
    }
  end

  @spec roll(Dice.t()) :: Dice.t()
  def roll(%Dice{state: :not_rolled} = dice) do
    %Dice{dice | roll: do_roll(dice.base), state: :rolled}
  end

  def roll(%Dice{state: :rolled} = dice) do
    if is_locked(dice) do
      dice
    else
      %Dice{dice | roll: do_roll(dice.base), state: :pushed}
    end
  end

  def roll(%Dice{state: :pushed} = dice) do
    dice
  end

  defp do_roll(base) do
    1..base
    |> Enum.take_random(1)
    |> hd()
  end

  @spec is_locked(Dice.t()) :: boolean()
  def is_locked(%Dice{} = dice) do
    fail_count(dice) > 0 || success_count(dice) > 0
  end

  @spec fail_count(Dice.t()) :: non_neg_integer()
  def fail_count(%Dice{} = dice) do
    fail_base_count(dice) + fail_gear_count(dice)
  end

  @spec fail_base_count(Dice.t()) :: non_neg_integer()
  def fail_base_count(%Dice{roll: 1, key: :base} = _dice), do: 1
  def fail_base_count(%Dice{} = _dice), do: 0

  @spec fail_gear_count(Dice.t()) :: non_neg_integer()
  def fail_gear_count(%Dice{roll: 1, key: :gear} = _dice), do: 1
  def fail_gear_count(%Dice{} = _dice), do: 0

  @spec success_count(Dice.t()) :: non_neg_integer()
  def success_count(%Dice{roll: roll} = _dice) when roll in [6, 7], do: 1
  def success_count(%Dice{roll: roll} = _dice) when roll in [8, 9], do: 2
  def success_count(%Dice{roll: roll} = _dice) when roll in [10, 11], do: 3
  def success_count(%Dice{roll: 12} = _dice), do: 4
  def success_count(%Dice{} = _dice), do: 0

  @spec types() :: list(atom())
  def types() do
    Enum.map(@types, fn %{key: key} -> key end)
  end

  @spec data_type(atom()) :: map()
  def data_type(type) do
    Enum.find(@types, fn %{key: key} -> type == key end)
  end
end
