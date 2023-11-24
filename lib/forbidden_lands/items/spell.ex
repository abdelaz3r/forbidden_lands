defmodule ForbiddenLands.Items.Spell do
  @moduledoc false

  import ForbiddenLandsWeb.Gettext

  alias ForbiddenLands.Items.Spell

  @exported_fields [
    :type,
    :rank,
    :name,
    :range,
    :duration,
    :ingredient,
    :is_official,
    :is_ritual,
    :is_power_word,
    :do_consume_ingredient,
    :desc_header,
    :desc_summary,
    :full_description,
    :name_length,
    :desc_length,
    :style
  ]

  @derive {ForbiddenLands.Export, fields: @exported_fields}
  @type t() :: %Spell{
          type: String.t() | nil,
          rank: integer() | nil,
          name: String.t() | nil,
          range: String.t() | nil,
          duration: String.t() | nil,
          ingredient: String.t() | nil,
          is_official: boolean() | nil,
          is_ritual: boolean() | nil,
          is_power_word: boolean() | nil,
          do_consume_ingredient: boolean() | nil,
          desc_header: String.t() | nil,
          desc_summary: String.t() | nil,
          full_description: String.t() | nil,
          name_length: integer() | nil,
          desc_length: integer() | nil,
          style: String.t() | nil
        }
  defstruct @exported_fields

  @spec from_json(map()) :: Spell.t()
  def from_json(spell) do
    description = Map.get(spell, "description", %{})
    header = Map.get(description, "header", "")
    summary = Map.get(description, "summary", []) |> Enum.join(" ")

    %Spell{
      type: Map.get(spell, "type"),
      rank: Map.get(spell, "rank"),
      name: Map.get(spell, "name"),
      range: Map.get(spell, "range"),
      duration: Map.get(spell, "duration"),
      ingredient: Map.get(spell, "ingredient"),
      is_official: Map.get(spell, "is_official"),
      is_ritual: Map.get(spell, "is_ritual"),
      is_power_word: Map.get(spell, "is_power_word"),
      do_consume_ingredient: Map.get(spell, "do_consume_ingredient"),
      desc_header: header,
      desc_summary: summary,
      full_description: Map.get(spell, "full_description"),
      name_length: String.length(Map.get(spell, "name")),
      desc_length: String.length(header <> summary),
      style: colors(Map.get(spell, "type"))
    }
  end

  @spec colors(String.t()) :: String.t()
  def colors("general"), do: "114, 114, 114"
  def colors("healing"), do: "83, 61, 151"
  def colors("shapeshifting"), do: "91, 153, 51"
  def colors("awareness"), do: "41, 169, 161"
  def colors("symbolism"), do: "53, 98, 180"
  def colors("stone_song"), do: "173, 109, 90"
  def colors("blood_magic"), do: "195, 35, 85"
  def colors("death_magic"), do: "137, 112, 140"
  def colors(_), do: "0, 0, 0"

  @spec patterns(String.t()) :: [integer()]
  def patterns("general"), do: [3, 1]
  def patterns("healing"), do: [1, 1, 4]
  def patterns("shapeshifting"), do: [2, 2, 2]
  def patterns("awareness"), do: [4, 2, 2]
  def patterns("symbolism"), do: [1, 2, 1, 2, 1]
  def patterns("stone_song"), do: [7, 1]
  def patterns("blood_magic"), do: [1, 1, 1, 1]
  def patterns("death_magic"), do: [2, 5, 1]
  def patterns(_), do: [5]

  @spec types(String.t()) :: String.t()
  def types("general"), do: dgettext("spells", "Common Magic")
  def types("healing"), do: dgettext("spells", "Healing")
  def types("shapeshifting"), do: dgettext("spells", "Shapeshifting")
  def types("awareness"), do: dgettext("spells", "Awareness")
  def types("symbolism"), do: dgettext("spells", "Symbolism")
  def types("stone_song"), do: dgettext("spells", "Stone Song")
  def types("blood_magic"), do: dgettext("spells", "Blood Magic")
  def types("death_magic"), do: dgettext("spells", "Death Magic")
  def types(_), do: dgettext("spells", "Unknown Magic")

  @spec durations(String.t()) :: String.t()
  def durations("immediate"), do: dgettext("spells", "Immediate")
  def durations("round"), do: dgettext("spells", "1 round")
  def durations("round_per_level"), do: dgettext("spells", "1 round/lvl.")
  def durations("turn"), do: dgettext("spells", "1 turn")
  def durations("turn_per_level"), do: dgettext("spells", "1 turn/lvl.")
  def durations("quarter"), do: dgettext("spells", "1 quarter")
  def durations("quarter_per_level"), do: dgettext("spells", "1 quarter/lvl.")
  def durations("varies"), do: dgettext("spells", "Varies")
  def durations(_), do: dgettext("spells", "—")

  @spec ranges(String.t()) :: String.t()
  def ranges("personal"), do: dgettext("spells", "Personal")
  def ranges("arms_length"), do: dgettext("spells", "Arm's length")
  def ranges("near"), do: dgettext("spells", "Near")
  def ranges("short"), do: dgettext("spells", "Short")
  def ranges("long"), do: dgettext("spells", "Long")
  def ranges("distant"), do: dgettext("spells", "Distant")
  def ranges("unlimited"), do: dgettext("spells", "Unlimited")
  def ranges("varies"), do: dgettext("spells", "Varies")
  def ranges(_), do: dgettext("spells", "—")
end
