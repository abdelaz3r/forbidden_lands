defmodule ForbiddenLandsWeb.Live.Spells do
  @moduledoc """
  Spells view.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
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

    socket =
      socket
      |> assign(page_title: dgettext("app", "Spells"))
      |> assign(spells_json: spells_json)
      |> assign(filters: Ecto.Changeset.change({%{text: nil}, %{text: :string}}))

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
          <div class="flex gap-5">
            <div class="grow">
              <.input field={{f, :text}} placeholder="Écrivez pour filtrer les sorts" autocomplete="off" />
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
                <div
                  class={[
                    "absolute flex justify-center items-center w-8 h-8 text-xl bg-white rounded-lg border rotate-45",
                    spell.is_ritual && "top-2 right-2",
                    not spell.is_ritual && "top-4 right-4"
                  ]}
                  style={"border-color: rgba(#{spell.style}, .3);"}
                >
                </div>
                <div
                  class={[
                    "absolute flex justify-center items-center w-8 h-8 text-xl bg-white rounded-md border",
                    spell.is_ritual && "top-2 right-2",
                    not spell.is_ritual && "top-4 right-4"
                  ]}
                  style={"
                  border-color: rgba(#{spell.style}, .5);
                  color: rgba(#{spell.style}, 1);
                "}
                >
                  <span class="relative top-0.5">
                    <%= spell.rank %>
                  </span>
                </div>
              </div>

              <div class="flex justify-between pb-2">
                <div class="flex items-baseline gap-2">
                  <span>
                    <%= spell.type %>
                  </span>
                  <span class="flex gap-1">
                    <span class="h-1 w-1 rounded-md" style={"background: rgba(#{spell.style}, 1);"}></span>
                    <span class="h-1 w-6 rounded-md" style={"background: rgba(#{spell.style}, 1);"}></span>
                    <span class="h-1 w-2 rounded-md" style={"background: rgba(#{spell.style}, 1);"}></span>
                  </span>
                </div>
                <span :if={spell.is_ritual}>
                  Rituel
                </span>
              </div>

              <div class="text-base border-t border-b" style={"border-color: rgba(#{spell.style}, .25);"}>
                <div class="flex justify-between pt-2">
                  <div><%= spell.range %></div>
                  <div><%= spell.duration %></div>
                </div>

                <div class="flex items-center gap-2 pb-2">
                  <%= if spell.ingredient do %>
                    <span :if={not spell.do_consume_ingredient} class="relative -top-0 w-2 h-2 rounded-sm bg-black"></span>
                    <span><%= spell.ingredient %></span>
                  <% else %>
                    —
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
                <span class="font-bold">
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
  def handle_event("update_filters", %{"filters" => %{"text" => text}}, socket) do
    socket =
      socket
      |> assign(filters_text: text)
      |> filter_json()

    {:noreply, socket}
  end

  defp filter_json(socket) do
    filters_text = Map.get(socket.assigns, :filters_text, "")

    spells =
      socket.assigns.spells_json
      |> Enum.filter(fn spell ->
        String.match?(spell["name"], ~r/#{filters_text}/i)
      end)
      |> Enum.map(fn spell ->
        %{
          type: type(spell["type"]),
          rank: spell["rank"],
          range: range(spell["range"]),
          name: spell["name"],
          name_length: String.length(spell["name"]),
          is_official: spell["is_official"],
          is_ritual: spell["is_ritual"],
          is_power_word: spell["is_power_word"],
          do_consume_ingredient: spell["do_consume_ingredient"],
          ingredient: spell["ingredient"],
          duration: duration(spell["duration"]),
          desc_header: spell["description"]["header"],
          desc_summary: Enum.join(spell["description"]["summary"], " "),
          desc_length:
            String.length(spell["description"]["header"] <> Enum.join(spell["description"]["summary"], " ")),
          style: color_by_type(spell["type"]),
          background: background(spell["type"], color_by_type(spell["type"]))
        }
      end)

    socket
    |> assign(filters_text: filters_text)
    |> assign(spells: spells)
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

  defp background("general", color) do
    "background: linear-gradient(to bottom left, rgba(#{color}, .1), rgba(#{color}, .0));"
  end

  defp background("healing", color) do
    "background-image:
       repeating-radial-gradient(circle at 0 0, transparent 0, rgba(#{color}, .08) 10px),
       repeating-linear-gradient(rgba(#{color}, .01), rgba(#{color}, .02));
     background-color: rgba(#{color}, .05);"
  end

  defp background("shapeshifting", color) do
    "--c: rgba(#{color}, .1);
     background:
       radial-gradient(circle at bottom left, var(--c) 35%, transparent 36%),
       radial-gradient(circle at top right, var(--c) 35%, transparent 36%),
       radial-gradient(circle at center, var(--c) 15%, transparent 16%);
     background-size: 2.2rem 2.2rem;
     background-position: -5px 0;"
  end

  defp background("awareness", color) do
    "--c: rgba(#{color}, .1);
     background: radial-gradient(
       circle at center, var(--c), var(--c) 10%, transparent 10%, transparent 20%, var(--c) 20%, var(--c) 30%,
       transparent 30%, transparent 40%, var(--c) 40%, var(--c) 50%, transparent 50%, transparent 60%, var(--c)
       60%, var(--c) 70%, transparent 70%, transparent 80%, var(--c) 80%, var(--c) 90%, transparent 90%);
     background-size: 3.25em 3.25em;
     background-position: 2px -10px;"
  end

  defp background("symbolism", color) do
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

  defp background("stone_song", color) do
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

  defp background("blood_magic", color) do
    "--c: rgba(#{color}, .18);
     background:
       linear-gradient(25deg, #ffffff 40%, transparent 41%, transparent 59%, #ffffff 60%),
       linear-gradient(90deg, transparent 45%, var(--c) 45%, var(--c) 55%, transparent 55%, transparent 20%, var(--c) 20%, var(--c) 30%,transparent 30%),
       linear-gradient(90deg, var(--c) 9%, transparent 10%);
     background-size: 2em 2em;
     background-position: 3px 0;"
  end

  defp background("death_magic", color) do
    "--c: rgba(#{color}, .15);
     background:
       radial-gradient(circle, transparent 25%, #ffffff  26%),
       linear-gradient(45deg, transparent 46%, var(--c) 47%, var(--c) 52%, transparent 53%),
       linear-gradient(135deg, transparent 46%, var(--c) 47%, var(--c) 52%, transparent 53%);
     background-size: 2em 2em;
     background-position: -3px -2px;"
  end

  defp background(_type, _color) do
    "background: white;"
  end

  # TODO: put that in i18n

  defp type("general"), do: "Magie commune"
  defp type("healing"), do: "Magie de soin"
  defp type("shapeshifting"), do: "Changeforme"
  defp type("awareness"), do: "Magie de l'Œil"
  defp type("symbolism"), do: "Symbolisme"
  defp type("stone_song"), do: "Chant de la Pierre"
  defp type("blood_magic"), do: "Magie du Sang"
  defp type("death_magic"), do: "Magie de la Mort"
  defp type(_), do: "Magie inconnue"

  defp duration("immediate"), do: "Immédiat"
  defp duration("round"), do: "1 round"
  defp duration("round_per_level"), do: "1 round/niv."
  defp duration("turn"), do: "1 tour"
  defp duration("turn_per_level"), do: "1 tour/niv."
  defp duration("quarter"), do: "1 quarter"
  defp duration("quarter_per_level"), do: "1 quarter/niv."
  defp duration("varies"), do: "—"
  defp duration(_), do: "—"

  defp range("personal"), do: "Sur soi"
  defp range("arms_length"), do: "Autour de soi"
  defp range("near"), do: "Zone courante"
  defp range("short"), do: "<25 mètres"
  defp range("long"), do: "<100 mètres"
  defp range("distant"), do: "Jusqu'à l'horizon"
  defp range("unlimited"), do: "Illimité"
  defp range("varies"), do: "Variable"
  defp range(_), do: "—"
end
