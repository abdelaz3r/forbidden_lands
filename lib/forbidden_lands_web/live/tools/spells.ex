defmodule ForbiddenLandsWeb.Live.Tools.Spells do
  @moduledoc """
  Spells view.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  alias ForbiddenLands.Items.Spell

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    # Load spells from JSON file
    file_path = List.to_string(:code.priv_dir(:forbidden_lands)) <> "/static/spells/#{Gettext.get_locale()}.json"

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
          MapSet.put(types, {Spell.types(spell["type"]), spell["type"]}),
          MapSet.put(durations, {Spell.durations(spell["duration"]), spell["duration"]}),
          MapSet.put(ranges, {Spell.ranges(spell["range"]), spell["range"]})
        }
      end)

    # Set ranks
    ranks = Enum.map(1..3, fn i -> {dgettext("spells", "Rank %{level}", level: i), i} end)

    # Transform spells JSON into a list of spells
    source = Enum.with_index(spells_json, fn spell, i -> Spell.from_json(spell, i) end)

    socket =
      socket
      |> assign(page_title: dgettext("app", "Spells list"))
      |> assign(source: source)
      |> assign(opened_spell: nil)
      |> assign(types: [{dgettext("spells", "All types"), "all"} | types |> MapSet.to_list()])
      |> assign(durations: [{dgettext("spells", "All durations"), "all"} | durations |> MapSet.to_list()])
      |> assign(ranges: [{dgettext("spells", "All ranges"), "all"} | ranges |> MapSet.to_list()])
      |> assign(ranks: [{dgettext("spells", "All ranks"), 0} | ranks])
      |> assign(filters: filter_changeset())

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, filter_spells(socket)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <section class="text-gray-900 bg-white border-t print:border-none">
      <div class="p-5 pb-0 border-b bg-gray-100 print:hidden">
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
          <div class="absolute inset-0" style={background(spell.type, spell.style)}></div>
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
                    <%= Spell.types(spell.type) %>
                  </span>
                  <span class="flex gap-1">
                    <span
                      :for={width <- Spell.patterns(spell.type)}
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
                  <div><%= Spell.ranges(spell.range) %></div>
                  <div><%= Spell.durations(spell.duration) %></div>
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
                <span>
                  <%= spell.desc_summary %>
                  <.icon
                    :if={spell.full_description}
                    phx-click="open"
                    phx-value-spell-id={spell.id}
                    name={:plus_circle}
                    class="relative -top-0.5 inline-block ml-1 h-3 w-3 cursor-pointer print:hidden"
                  />
                </span>
              </div>
            </div>

            <div :if={spell.id == @opened_spell} class="absolute inset-0 p-4 bg-white font-['Crimson_Pro'] print:hidden">
              <div class="absolute inset-0 py-3 px-4 overflow-y-auto" style={"background: rgba(#{spell.style}, .5);"}>
                <div class="font-bold">
                  <%= dgettext("spells", "Original description") %>
                </div>
                <%= spell.full_description %>
              </div>
              <.icon phx-click="close" name={:x_circle} class="absolute h-4 w-4 top-2 right-2 cursor-pointer" />
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
      |> filter_spells()

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("open", %{"spell-id" => id}, socket) do
    {:noreply, assign(socket, opened_spell: String.to_integer(id))}
  end

  @impl Phoenix.LiveView
  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, opened_spell: nil)}
  end

  defp filter_changeset(params \\ %{}) do
    {
      %{"text" => nil, "type" => nil, "duration" => nil, "range" => nil, "rank" => nil},
      %{"text" => :string, "type" => :string, "duration" => :string, "range" => :string, "rank" => :integer}
    }
    |> Ecto.Changeset.change(params)
    |> Ecto.Changeset.apply_changes()
  end

  defp filter_spells(socket) do
    filters_text = Map.get(socket.assigns, :filters_text, "")
    filters_type = Map.get(socket.assigns, :filters_type, "all")
    filters_duration = Map.get(socket.assigns, :filters_duration, "all")
    filters_range = Map.get(socket.assigns, :filters_range, "all")
    filters_rank = Map.get(socket.assigns, :filters_rank, 0)

    spells =
      socket.assigns.source
      |> Enum.filter(fn spell ->
        String.match?(spell.name, ~r/#{filters_text}/i) and
          (filters_type == "all" or spell.type == filters_type) and
          (filters_duration == "all" or spell.duration == filters_duration) and
          (filters_range == "all" or spell.range == filters_range) and
          (filters_rank == 0 or spell.rank == filters_rank)
      end)
      |> Enum.sort_by(fn spell -> spell.rank end)
      |> Enum.sort_by(fn spell -> spell.type end)

    assign(socket, spells: spells)
  end

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
end
