defmodule ForbiddenLands.Instances.Stronghold do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import ForbiddenLandsWeb.Gettext

  alias ForbiddenLands.Instances.Stronghold

  @resource_fields [
    :coins,
    :iron_ore,
    :iron,
    :silver_ore,
    :silver,
    :gold_ore,
    :gold,
    :stone,
    :wood,
    :leather,
    :fur,
    :wool,
    :cloth,
    :grain,
    :flour,
    :meat,
    :fish,
    :vegetables,
    :food,
    :tallow,
    :herbs,
    :glass,
    :beer
  ]

  @exported_fields [
    :name,
    :description,
    :defense,
    :reputation,
    :functions,
    :hirelings,
    :tools,
    :items
  ]

  @derive {ForbiddenLands.Export, fields: @exported_fields ++ @resource_fields}
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
          silver_ore: non_neg_integer() | nil,
          silver: non_neg_integer() | nil,
          gold_ore: non_neg_integer() | nil,
          gold: non_neg_integer() | nil,
          stone: non_neg_integer() | nil,
          wood: non_neg_integer() | nil,
          leather: non_neg_integer() | nil,
          fur: non_neg_integer() | nil,
          wool: non_neg_integer() | nil,
          cloth: non_neg_integer() | nil,
          grain: non_neg_integer() | nil,
          flour: non_neg_integer() | nil,
          meat: non_neg_integer() | nil,
          fish: non_neg_integer() | nil,
          vegetables: non_neg_integer() | nil,
          food: non_neg_integer() | nil,
          tallow: non_neg_integer() | nil,
          herbs: non_neg_integer() | nil,
          glass: non_neg_integer() | nil,
          beer: non_neg_integer() | nil
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
    field(:silver_ore, :integer, default: 0)
    field(:silver, :integer, default: 0)
    field(:gold_ore, :integer, default: 0)
    field(:gold, :integer, default: 0)
    field(:stone, :integer, default: 0)
    field(:wood, :integer, default: 0)
    field(:leather, :integer, default: 0)
    field(:fur, :integer, default: 0)
    field(:wool, :integer, default: 0)
    field(:cloth, :integer, default: 0)
    field(:grain, :integer, default: 0)
    field(:flour, :integer, default: 0)
    field(:meat, :integer, default: 0)
    field(:fish, :integer, default: 0)
    field(:vegetables, :integer, default: 0)
    field(:food, :integer, default: 0)
    field(:tallow, :integer, default: 0)
    field(:herbs, :integer, default: 0)
    field(:glass, :integer, default: 0)
    field(:beer, :integer, default: 0)
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

  @spec resource_fields() :: [atom()]
  def resource_fields() do
    @resource_fields
  end

  @spec resource_name(atom(), integer()) :: String.t()
  def resource_name(type, amount) when amount < 0, do: resource_name(type, abs(amount))
  def resource_name(:coins, x), do: dngettext("app", "copper coin", "copper coins", x)
  def resource_name(:iron_ore, x), do: dngettext("app", "iron ore", "iron ores", x)
  def resource_name(:iron, x), do: dngettext("app", "iron ingot", "iron ingots", x)
  def resource_name(:silver_ore, x), do: dngettext("app", "silver ore", "silver ores", x)
  def resource_name(:silver, x), do: dngettext("app", "silver ingot", "silver ingots", x)
  def resource_name(:gold_ore, x), do: dngettext("app", "gold ore", "gold ores", x)
  def resource_name(:gold, x), do: dngettext("app", "gold ingot", "gold ingots", x)
  def resource_name(:stone, x), do: dngettext("app", "stone block", "stone blocks", x)
  def resource_name(:glass, x), do: dngettext("app", "glass crate", "glass crates", x)
  def resource_name(:wood, x), do: dngettext("app", "wood log", "wood logs", x)
  def resource_name(:fur, x), do: dngettext("app", "fur", "furs", x)
  def resource_name(:leather, x), do: dngettext("app", "leather roll", "leather rolls", x)
  def resource_name(:cloth, x), do: dngettext("app", "cloth", "cloths", x)
  def resource_name(:wool, x), do: dngettext("app", "wool ball", "wool balls", x)
  def resource_name(:food, x), do: dngettext("app", "ration", "rations", x)
  def resource_name(:flour, x), do: dngettext("app", "flour sack", "flour sacks", x)
  def resource_name(:grain, x), do: dngettext("app", "grain sack", "grain sacks", x)
  def resource_name(:meat, x), do: dngettext("app", "meat ration", "meat rations", x)
  def resource_name(:fish, x), do: dngettext("app", "fish ration", "fish rations", x)
  def resource_name(:vegetables, x), do: dngettext("app", "vegetable ration", "vegetable rations", x)
  def resource_name(:tallow, x), do: dngettext("app", "tallow jar", "tallow jars", x)
  def resource_name(:herbs, x), do: dngettext("app", "herb bundle", "herb bundles", x)
  def resource_name(:beer, x), do: dngettext("app", "beer barrel", "beer barrels", x)
  def resource_name(_type, _), do: dgettext("app", "unknown resource")

  defp validate_resource_field(stronghold) do
    Enum.reduce(@resource_fields, stronghold, fn field, acc ->
      validate_number(acc, field, greater_than_or_equal_to: 0)
    end)
  end
end
