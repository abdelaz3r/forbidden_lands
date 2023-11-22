defmodule ForbiddenLandsWeb.Live.Spells do
  @moduledoc """
  Spells view.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    # Load spells from JSON file
    file_path =
      List.to_string(:code.priv_dir(:forbidden_lands)) <>
        "/static/spells/#{Gettext.get_locale()}.json"

    spells_json =
      with {:ok, file} <- File.read(file_path),
           {:ok, json} <- Poison.decode(file) do
        json
      else
        false -> []
        {:error, _reason} -> []
      end

    # Extract dynamic types, durations and ranges
    {types, durations, ranges} =
      spells_json
      |> Enum.reduce({MapSet.new(), MapSet.new(), MapSet.new()}, fn spell, {types, durations, ranges} ->
        {
          MapSet.put(types, {type_locale(spell["type"]), spell["type"]}),
          MapSet.put(durations, {duration_locale(spell["duration"]), spell["duration"]}),
          MapSet.put(ranges, {range_locale(spell["range"]), spell["range"]})
        }
      end)

    # Set ranks
    ranks = Enum.map(1..3, fn i -> {dgettext("spells", "Rank %{level}", level: i), i} end)

    socket =
      socket
      |> assign(page_title: dgettext("app", "Spells list"))
      |> assign(spells_json: spells_json)
      |> assign(types: [{dgettext("spells", "All types"), "all"} | types |> MapSet.to_list()])
      |> assign(durations: [{dgettext("spells", "All durations"), "all"} | durations |> MapSet.to_list()])
      |> assign(ranges: [{dgettext("spells", "All ranges"), "all"} | ranges |> MapSet.to_list()])
      |> assign(ranks: [{dgettext("spells", "All ranks"), 0} | ranks])
      |> assign(filters: filter_changeset())

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, filter_json(socket)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <section class="text-gray-900 bg-white border-t print:border-none">
      <div class="p-5 pb-0 border-b print:hidden">
        <.simple_form :let={f} as={:filters} for={@filters} phx-change="update_filters">
          <div class="flex flex-col md:flex-row md:gap-5">
            <div class="grow">
              <.input field={{f, :text}} placeholder={dgettext("spells", "Type to filter spells")} autocomplete="off" />
            </div>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-x-5">
              <.input field={{f, :type}} type="select" options={@types} />
              <.input field={{f, :duration}} type="select" options={@durations} />
              <.input field={{f, :range}} type="select" options={@ranges} />
              <.input field={{f, :rank}} type="select" options={@ranks} />
            </div>
          </div>
        </.simple_form>
      </div>

      <div class="p-2 text-center print:p-0">
        <div
          :for={spell <- @spells}
          class="relative text-left overflow-hidden m-2 w-[290px] h-[403px] inline-block align-top text-sm border-8 rounded bg-white"
          style={"border-color: rgba(#{spell.style}, .5);"}
        >
          <div class="absolute inset-0" style={spell.background}></div>
          <div class="absolute top-4 left-0 h-8 border-4 border-transparent border-l-white"></div>
          <div class="absolute top-4 left-0 h-8 border-4 border-transparent" style={"border-left-color: rgba(#{spell.style}, .5);"}>
          </div>
          <div class="absolute bottom-0 left-20 right-20 border-4 border-transparent border-b-white"></div>
          <div
            class="absolute bottom-0 left-20 right-20 border-4 border-transparent"
            style={"border-bottom-color: rgba(#{spell.style}, .5);"}
          >
          </div>
          <div :if={not spell.is_official} class="absolute top-1 left-1 w-2 h-2 rounded-full bg-black"></div>
          <div class="absolute inset-0 flex flex-col p-4">
            <div class="flex-none font-['Satisfy']">
              <div class="font-bold">
                <div class={[
                  "text-2xl",
                  spell.name_length > 18 && "tracking-tight",
                  spell.name_length > 22 && "tracking-tighter"
                ]}>
                  <%= spell.name %>
                </div>
                <div class={[
                  "absolute w-8 h-8",
                  (spell.is_ritual or spell.is_power_word) && "top-2 right-2",
                  not (spell.is_ritual or spell.is_power_word) && "top-4 right-4"
                ]}>
                  <div
                    class="absolute inset-0 bg-white rounded-lg border rotate-45"
                    style={"border-color: rgba(#{spell.style}, .3);"}
                  >
                  </div>
                  <div
                    class="absolute flex inset-0 justify-center items-center text-xl bg-white rounded-md border"
                    style={"border-color: rgba(#{spell.style}, .5); color: rgba(#{spell.style}, 1);"}
                  >
                    <span class="relative top-0.5">
                      <%= spell.rank %>
                    </span>
                  </div>
                </div>
              </div>

              <div class="flex justify-between pb-2">
                <div class="flex items-baseline gap-2">
                  <span>
                    <%= spell.type_locale %>
                  </span>
                  <span class="flex gap-1">
                    <span
                      :for={width <- spell.pattern}
                      class="h-1 rounded-md"
                      style={"background: rgba(#{spell.style}, 1); width: #{width * 4}px;"}
                    >
                    </span>
                  </span>
                </div>
                <div>
                  <span :if={spell.is_ritual}>
                    <%= dgettext("spells", "Ritual") %>
                  </span>
                  <span :if={spell.is_power_word}>
                    <%= dgettext("spells", "Power word") %>
                  </span>
                </div>
              </div>

              <div class="text-base border-t border-b" style={"border-color: rgba(#{spell.style}, .25);"}>
                <div class="flex justify-between pt-2">
                  <div><%= spell.range_locale %></div>
                  <div><%= spell.duration_locale %></div>
                </div>

                <div class="flex items-center gap-2 pb-2">
                  <%= if spell.ingredient do %>
                    <span><%= spell.ingredient %></span>
                    <.icon :if={not spell.do_consume_ingredient} name={:infinity} class="h-4 w-4 " />
                  <% else %>
                    ————
                  <% end %>
                </div>
              </div>
            </div>

            <div class={[
              "grow flex flex-col gap-1 pt-2 font-['Crimson_Pro']",
              spell.desc_length > 450 && "leading-4",
              spell.desc_length > 550 && "text-[13px] leading-4"
            ]}>
              <div>
                <span class={["font-bold", spell.desc_length < 310 && "block pb-2"]}>
                  <%= spell.desc_header %>
                </span>
                <%= spell.desc_summary %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("update_filters", %{"filters" => changeset}, socket) do
    socket =
      socket
      |> assign(filters: filter_changeset(changeset))
      |> assign(filters_text: changeset["text"])
      |> assign(filters_type: changeset["type"])
      |> assign(filters_duration: changeset["duration"])
      |> assign(filters_range: changeset["range"])
      |> assign(filters_rank: String.to_integer(changeset["rank"]))
      |> filter_json()

    {:noreply, socket}
  end

  defp filter_changeset(params \\ %{}) do
    {
      %{"text" => nil, "type" => nil, "duration" => nil, "range" => nil, "rank" => nil},
      %{"text" => :string, "type" => :string, "duration" => :string, "range" => :string, "rank" => :integer}
    }
    |> Ecto.Changeset.change(params)
    |> Ecto.Changeset.apply_changes()
  end

  defp filter_json(socket) do
    filters_text = Map.get(socket.assigns, :filters_text, "")
    filters_type = Map.get(socket.assigns, :filters_type, "all")
    filters_duration = Map.get(socket.assigns, :filters_duration, "all")
    filters_range = Map.get(socket.assigns, :filters_range, "all")
    filters_rank = Map.get(socket.assigns, :filters_rank, 0)

    spells =
      socket.assigns.spells_json
      |> Enum.filter(fn spell ->
        String.match?(spell["name"], ~r/#{filters_text}/i) and
          (filters_type == "all" or spell["type"] == filters_type) and
          (filters_duration == "all" or spell["duration"] == filters_duration) and
          (filters_range == "all" or spell["range"] == filters_range) and
          (filters_rank == 0 or spell["rank"] == filters_rank)
      end)
      |> Enum.sort_by(fn spell -> spell["rank"] end)
      |> Enum.sort_by(fn spell -> spell["type"] end)
      |> Enum.map(fn spell ->
        %{
          type: spell["type"],
          type_locale: type_locale(spell["type"]),
          rank: spell["rank"],
          range: spell["range"],
          range_locale: range_locale(spell["range"]),
          name: spell["name"],
          name_length: String.length(spell["name"]),
          is_official: spell["is_official"],
          is_ritual: spell["is_ritual"],
          is_power_word: spell["is_power_word"],
          do_consume_ingredient: spell["do_consume_ingredient"],
          ingredient: spell["ingredient"],
          duration: spell["duration"],
          duration_locale: duration_locale(spell["duration"]),
          desc_header: spell["description"]["header"],
          desc_summary: Enum.join(spell["description"]["summary"], " "),
          desc_length:
            String.length(spell["description"]["header"] <> Enum.join(spell["description"]["summary"], " ")),
          style: color_by_type(spell["type"]),
          background: background_by_type(spell["type"], color_by_type(spell["type"])),
          pattern: pattern_by_type(spell["type"])
        }
      end)

    assign(socket, spells: spells)
  end

  defp color_by_type("general"), do: "114, 114, 114"
  defp color_by_type("healing"), do: "83, 61, 151"
  defp color_by_type("shapeshifting"), do: "91, 153, 51"
  defp color_by_type("awareness"), do: "41, 169, 161"
  defp color_by_type("symbolism"), do: "53, 98, 180"
  defp color_by_type("stone_song"), do: "173, 109, 90"
  defp color_by_type("blood_magic"), do: "195, 35, 85"
  defp color_by_type("death_magic"), do: "137, 112, 140"
  defp color_by_type(_), do: "0, 0, 0"

  defp pattern_by_type("general"), do: [3, 1]
  defp pattern_by_type("healing"), do: [1, 1, 4]
  defp pattern_by_type("shapeshifting"), do: [2, 2, 2]
  defp pattern_by_type("awareness"), do: [4, 2, 2]
  defp pattern_by_type("symbolism"), do: [1, 2, 1, 2, 1]
  defp pattern_by_type("stone_song"), do: [7, 1]
  defp pattern_by_type("blood_magic"), do: [1, 1, 1, 1]
  defp pattern_by_type("death_magic"), do: [2, 5, 1]
  defp pattern_by_type(_), do: [5]

  defp background_by_type("general", color) do
    "background: linear-gradient(to bottom left, rgba(#{color}, .1), rgba(#{color}, .0));"
  end

  defp background_by_type("healing", color) do
    "background-image:
       repeating-radial-gradient(circle at 0 0, transparent 0, rgba(#{color}, .08) 10px),
       repeating-linear-gradient(rgba(#{color}, .01), rgba(#{color}, .02));
     background-color: rgba(#{color}, .05);"
  end

  defp background_by_type("shapeshifting", color) do
    "--c: rgba(#{color}, .1);
     background:
       radial-gradient(circle at bottom left, var(--c) 35%, transparent 36%),
       radial-gradient(circle at top right, var(--c) 35%, transparent 36%),
       radial-gradient(circle at center, var(--c) 15%, transparent 16%);
     background-size: 2.2rem 2.2rem;
     background-position: -5px 0;"
  end

  defp background_by_type("awareness", color) do
    "--c: rgba(#{color}, .1);
     background: radial-gradient(
       circle at center, var(--c), var(--c) 10%, transparent 10%, transparent 20%, var(--c) 20%, var(--c) 30%,
       transparent 30%, transparent 40%, var(--c) 40%, var(--c) 50%, transparent 50%, transparent 60%, var(--c)
       60%, var(--c) 70%, transparent 70%, transparent 80%, var(--c) 80%, var(--c) 90%, transparent 90%);
     background-size: 3.25em 3.25em;
     background-position: 2px -10px;"
  end

  defp background_by_type("symbolism", color) do
    "--c: rgba(#{color}, .1);
     background:
       linear-gradient(45deg, transparent 34%, var(--c) 35%, var(--c) 40%, transparent 41%, transparent 59%, var(--c)  60%, var(--c) 65%, transparent 66%),
       linear-gradient(135deg, transparent 34%, var(--c) 35%, var(--c) 40%, transparent 41%, transparent 59%, var(--c)  60%, var(--c) 65%, transparent 66%),
       radial-gradient(var(--c) 10%, transparent 11%),
       radial-gradient(circle at left, var(--c) 5%, transparent 6%),
       radial-gradient(circle at right, var(--c) 5%, transparent 6%),
       radial-gradient(circle at top, var(--c) 5%, transparent 6%),
       radial-gradient(circle at bottom, var(--c) 5%, transparent 6%);
     background-size: 2em 2em;
     background-position: -3px -3px;"
  end

  defp background_by_type("stone_song", color) do
    "--c: rgba(#{color}, .25);
     background:
       radial-gradient(circle, var(--c) 10%, transparent 11%),
       radial-gradient(circle at bottom left, var(--c) 5%, transparent 6%),
       radial-gradient(circle at bottom right, var(--c) 5%, transparent 6%),
       radial-gradient(circle at top left, var(--c) 5%, transparent 6%),
       radial-gradient(circle at top right, var(--c) 5%, transparent 6%);
     background-size: 1em 1em;
     background-position: 0 -3px;"
  end

  defp background_by_type("blood_magic", color) do
    "--c: rgba(#{color}, .18);
     background:
       linear-gradient(25deg, #ffffff 40%, transparent 41%, transparent 59%, #ffffff 60%),
       linear-gradient(90deg, transparent 45%, var(--c) 45%, var(--c) 55%, transparent 55%, transparent 20%, var(--c) 20%, var(--c) 30%,transparent 30%),
       linear-gradient(90deg, var(--c) 9%, transparent 10%);
     background-size: 2em 2em;
     background-position: 3px 0;"
  end

  defp background_by_type("death_magic", color) do
    "--c: rgba(#{color}, .15);
     background:
       radial-gradient(circle, transparent 25%, #ffffff  26%),
       linear-gradient(45deg, transparent 46%, var(--c) 47%, var(--c) 52%, transparent 53%),
       linear-gradient(135deg, transparent 46%, var(--c) 47%, var(--c) 52%, transparent 53%);
     background-size: 2em 2em;
     background-position: -3px -2px;"
  end

  defp background_by_type(_type, _color) do
    "background: white;"
  end

  defp type_locale("general"), do: dgettext("spells", "Common Magic")
  defp type_locale("healing"), do: dgettext("spells", "Healing")
  defp type_locale("shapeshifting"), do: dgettext("spells", "Shapeshifting")
  defp type_locale("awareness"), do: dgettext("spells", "Awareness")
  defp type_locale("symbolism"), do: dgettext("spells", "Symbolism")
  defp type_locale("stone_song"), do: dgettext("spells", "Stone Song")
  defp type_locale("blood_magic"), do: dgettext("spells", "Blood Magic")
  defp type_locale("death_magic"), do: dgettext("spells", "Death Magic")
  defp type_locale(_), do: dgettext("spells", "Unknown Magic")

  defp duration_locale("immediate"), do: dgettext("spells", "Immediate")
  defp duration_locale("round"), do: dgettext("spells", "1 round")
  defp duration_locale("round_per_level"), do: dgettext("spells", "1 round/lvl.")
  defp duration_locale("turn"), do: dgettext("spells", "1 turn")
  defp duration_locale("turn_per_level"), do: dgettext("spells", "1 turn/lvl.")
  defp duration_locale("quarter"), do: dgettext("spells", "1 quarter")
  defp duration_locale("quarter_per_level"), do: dgettext("spells", "1 quarter/lvl.")
  defp duration_locale("varies"), do: dgettext("spells", "Varies")
  defp duration_locale(_), do: dgettext("spells", "—")

  defp range_locale("personal"), do: dgettext("spells", "Personal")
  defp range_locale("arms_length"), do: dgettext("spells", "Arm's length")
  defp range_locale("near"), do: dgettext("spells", "Near")
  defp range_locale("short"), do: dgettext("spells", "Short")
  defp range_locale("long"), do: dgettext("spells", "Long")
  defp range_locale("distant"), do: dgettext("spells", "Distant")
  defp range_locale("unlimited"), do: dgettext("spells", "Unlimited")
  defp range_locale("varies"), do: dgettext("spells", "Varies")
  defp range_locale(_), do: dgettext("spells", "—")
end
