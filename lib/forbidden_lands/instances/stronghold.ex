defmodule ForbiddenLands.Instances.Stronghold do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias ForbiddenLands.Instances.Stronghold

  @resource_fields [
    :coins,
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
  ]

  @derive {ForbiddenLands.Export,
           fields:
             [:name, :description, :defense, :reputation, :functions, :hirelings, :tools, :items] ++
               @resource_fields}
  @type t() :: %Stronghold{
          name: String.t() | nil,
          description: String.t() | nil,
          defense: non_neg_integer() | nil,
          reputation: non_neg_integer() | nil,
          coins: non_neg_integer() | nil,
          functions: String.t() | nil,
          hirelings: String.t() | nil,
          tools: String.t() | nil,
          items: String.t() | nil,
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
    field(:description, :string)
    field(:defense, :integer, default: 0)
    field(:reputation, :integer, default: 0)
    field(:coins, :integer, default: 0)
    field(:functions, :string)
    field(:hirelings, :string)
    field(:tools, :string)
    field(:items, :string)
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
    |> cast(
      params,
      [:name, :description, :defense, :reputation, :functions, :hirelings, :tools, :items] ++ @resource_fields
    )
    |> validate_required([:name])
    |> validate_resource_field()
  end

  @spec coins_to_type(non_neg_integer(), atom()) :: non_neg_integer()
  def coins_to_type(coins, :copper) do
    {copper, _silver, _gold} = coins_to_type(coins)
    copper
  end

  def coins_to_type(coins, :silver) do
    {_copper, silver, _gold} = coins_to_type(coins)
    silver
  end

  def coins_to_type(coins, :gold) do
    {_copper, _silver, gold} = coins_to_type(coins)
    gold
  end

  @spec coins_to_type(non_neg_integer()) :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}
  def coins_to_type(coins) do
    gold = floor(coins / 100)
    rest = coins - gold * 100

    silver = floor(rest / 10)
    copper = rest - silver * 10

    {copper, silver, gold}
  end

  def resource_fields() do
    @resource_fields
  end

  def resource_name(:coins, x) when x <= 1, do: "pièce de cuivre"
  def resource_name(:coins, _), do: "pièces de cuivre"
  def resource_name(:iron_ore, x) when x <= 1, do: "minerai de fer"
  def resource_name(:iron_ore, _), do: " minerais de fer"
  def resource_name(:iron, x) when x <= 1, do: "lingot de fer"
  def resource_name(:iron, _), do: "lingots de fer"
  def resource_name(:silver, x) when x <= 1, do: "minerai d'argent"
  def resource_name(:silver, _), do: "minerais d'argent"
  def resource_name(:gold, x) when x <= 1, do: "minerai d'or"
  def resource_name(:gold, _), do: "minerais d'or"
  def resource_name(:stone, x) when x <= 1, do: "bloc de pierre"
  def resource_name(:stone, _), do: "blocs de pierre"
  def resource_name(:glass, x) when x <= 1, do: "unité de verre"
  def resource_name(:glass, _), do: "unités de verre"
  def resource_name(:wood, x) when x <= 1, do: "rondin de bois"
  def resource_name(:wood, _), do: "rondins de bois"
  def resource_name(:fur, x) when x <= 1, do: "unité de fourrure"
  def resource_name(:fur, _), do: "unités de fourrure"
  def resource_name(:leather, x) when x <= 1, do: "unité de cuire"
  def resource_name(:leather, _), do: "unités de cuire"
  def resource_name(:cloth, x) when x <= 1, do: "vêtement"
  def resource_name(:cloth, _), do: "vêtements"
  def resource_name(:wool, x) when x <= 1, do: "unité de laine"
  def resource_name(:wool, _), do: "unités de laine"
  def resource_name(:food, x) when x <= 1, do: "ration"
  def resource_name(:food, _), do: "rations"
  def resource_name(:water, x) when x <= 1, do: "unité d'eau"
  def resource_name(:water, _), do: "unités d'eau"
  def resource_name(:flour, x) when x <= 1, do: "unité de farine"
  def resource_name(:flour, _), do: "unités de farine"
  def resource_name(:grain, x) when x <= 1, do: "unité de grain"
  def resource_name(:grain, _), do: "unités de grain"
  def resource_name(:meat, x) when x <= 1, do: "ration de viande"
  def resource_name(:meat, _), do: "rations de viande"
  def resource_name(:fish, x) when x <= 1, do: "ration de poisson"
  def resource_name(:fish, _), do: "rations de poisson"
  def resource_name(:vegetables, x) when x <= 1, do: "ration de légumes"
  def resource_name(:vegetables, _), do: "rations de légumes"
  def resource_name(:tallow, x) when x <= 1, do: "bocal de suif"
  def resource_name(:tallow, _), do: "bocaux de suif"
  def resource_name(:herbs, x) when x <= 1, do: "unité d'herbe"
  def resource_name(:herbs, _), do: "unités d'herbe"
  def resource_name(_type, _), do: "ressource inconnue"

  defp validate_resource_field(stronghold) do
    Enum.reduce(@resource_fields, stronghold, fn field, acc ->
      validate_number(acc, field, greater_than_or_equal_to: 0)
    end)
  end
end
