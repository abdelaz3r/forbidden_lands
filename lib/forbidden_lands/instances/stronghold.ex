defmodule ForbiddenLands.Instances.Stronghold do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Instances.Stronghold

  @type t() :: %Stronghold{
          name: String.t() | nil,
          location: String.t() | nil,
          description: String.t() | nil,
          defense: non_neg_integer() | nil,
          coins: non_neg_integer() | nil,
          functions: String.t() | nil,
          hireling: String.t() | nil,
          iron_ore: non_neg_integer() | nil,
          iron: non_neg_integer() | nil,
          silver: non_neg_integer() | nil,
          gold: non_neg_integer() | nil,
          stone: non_neg_integer() | nil,
          glass: non_neg_integer() | nil,
          wood: non_neg_integer() | nil,
          fur: non_neg_integer() | nil,
          leather: non_neg_integer() | nil,
          cloth: non_neg_integer() | nil,
          wool: non_neg_integer() | nil,
          food: non_neg_integer() | nil,
          water: non_neg_integer() | nil,
          flour: non_neg_integer() | nil,
          grain: non_neg_integer() | nil,
          meat: non_neg_integer() | nil,
          fish: non_neg_integer() | nil,
          vegetables: non_neg_integer() | nil,
          tallow: non_neg_integer() | nil,
          herbs: non_neg_integer() | nil
        }
  embedded_schema do
    field(:name, :string)
    field(:location, :string)
    field(:description, :string)
    field(:defense, :integer, default: 0)
    field(:coins, :integer, default: 0)
    field(:functions, :string)
    field(:hireling, :string)
    field(:iron_ore, :integer, default: 0)
    field(:iron, :integer, default: 0)
    field(:silver, :integer, default: 0)
    field(:gold, :integer, default: 0)
    field(:stone, :integer, default: 0)
    field(:glass, :integer, default: 0)
    field(:wood, :integer, default: 0)
    field(:fur, :integer, default: 0)
    field(:leather, :integer, default: 0)
    field(:cloth, :integer, default: 0)
    field(:wool, :integer, default: 0)
    field(:food, :integer, default: 0)
    field(:water, :integer, default: 0)
    field(:flour, :integer, default: 0)
    field(:grain, :integer, default: 0)
    field(:meat, :integer, default: 0)
    field(:fish, :integer, default: 0)
    field(:vegetables, :integer, default: 0)
    field(:tallow, :integer, default: 0)
    field(:herbs, :integer, default: 0)
  end

  @spec changeset(Stronghold.t(), map()) :: Ecto.Changeset.t()
  def changeset(stronghold, params \\ %{}) do
    stronghold
    |> cast(params, [
      :name,
      :location,
      :description,
      :defense,
      :coins,
      :functions,
      :hireling,
      :iron_ore,
      :iron,
      :silver,
      :gold,
      :stone,
      :glass,
      :wood,
      :fur,
      :leather,
      :cloth,
      :wool,
      :food,
      :water,
      :flour,
      :grain,
      :meat,
      :fish,
      :vegetables,
      :tallow,
      :herbs
    ])
    |> validate_required([:name])
  end

  @spec coins_to_type(non_neg_integer()) :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}
  def coins_to_type(coins) do
    gold = floor(coins / 100)
    rest = coins - gold * 100

    silver = floor(rest / 10)
    copper = rest - silver * 10

    {copper, silver, gold}
  end
end
