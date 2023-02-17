defmodule ForbiddenLandsWeb.Live.Dashboard.Stronghold do
  @moduledoc """
  TODO.
  """

  use ForbiddenLandsWeb, :html

  alias ForbiddenLands.Instances.Stronghold

  attr(:stronghold, :map, required: true, doc: "todo")
  attr(:open?, :boolean, required: true, doc: "todo")
  attr(:class, :string, default: "", doc: "todo")

  @spec stronghold(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def stronghold(assigns) do
    ~H"""
    <div
      :if={@stronghold}
      class={[
        "flex-none font-title border-t border-slate-900 shadow-2xl shadow-black/50 bg-gradient-to-l from-slate-800",
        "to-slate-900 transition-all duration-500 relative",
        if(@open?, do: "h-[434px]", else: "h-[140px]"),
        @class
      ]}
    >
      <button type="button" class="absolute -top-10 w-full p-2" phx-click="toggle_stronghold">
        <Heroicons.chevron_double_up class={["h-6 w-6 m-auto transition-all duration-500", @open? && "rotate-180"]} />
      </button>

      <div class="p-4">
        <h1 class="flex justify-between text-lg font-bold pb-4">
          <div>
            <%= @stronghold.name %>
          </div>
          <div>
            <span class="uppercase text-slate-100/40 text-sm">def.</span>
            <%= @stronghold.defense %>
          </div>
        </h1>

        <div class="flex gap-4 mb-4">
          <div class="flex grow gap-2 border border-slate-800 p-4 bg-slate-900/60 justify-around">
            <div :for={type <- [:copper, :silver, :gold]} class="flex gap-2 items-center flex-none">
              <Heroicons.circle_stack class={[
                "float-left w-7 p-1 rounded-full border outline outline-offset-2 outline-2",
                coins_class(type)
              ]} />
              <span class="font-bold text-lg">
                <%= Stronghold.coins_to_type(@stronghold.coins, type) %>
              </span>
            </div>
          </div>
          <div class="border border-slate-800 py-2 px-4 bg-slate-900/60 justify-around flex gap-2 items-center flex-none">
            <Heroicons.chat_bubble_left_right class="float-left w-7 p-1 rounded-full border outline outline-offset-2 outline-2 bg-cyan-200 border-cyan-100 outline-cyan-100/10 text-cyan-700" />
            <span class="text-xl font-bold">
              <%= @stronghold.reputation %>
            </span>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-1 tabular-nums">
          <div :for={type <- Stronghold.resource_fields()} :if={type != :coins} class="flex gap-1 items-baseline">
            <span class="inline-flex font-bold items-baseline">
              <span class="text-slate-100/10"><%= leading_zeros(Map.get(@stronghold, type)) %></span>
              <%= Enum.min([9999, Map.get(@stronghold, type)]) %>
            </span>
            <span class="text-slate-100/60 text-sm truncate">
              <%= Stronghold.resource_name(type, Map.get(@stronghold, type)) %>
            </span>
          </div>
        </div>
      </div>

      <div class={[
        "grid grid-cols-2 gap-4 absolute left-[-700px] w-[700px] transition-all duration-500 p-4",
        if(@open?, do: "bottom-0 opacity-100", else: "bottom-[-1000px] opacity-0")
      ]}>
        <div class="flex flex-col justify-end gap-4">
          <.bloc_content :if={@stronghold.items} underlined?={false} title="Trésor & Possessions" content={@stronghold.items} />
          <.bloc_content :if={@stronghold.hirelings} underlined?={true} title="Gardes & Employés" content={@stronghold.hirelings} />
        </div>
        <div class="flex flex-col justify-end gap-4">
          <.bloc_content :if={@stronghold.description} underlined?={false} content={@stronghold.description} />
          <.bloc_content :if={@stronghold.tools} underlined?={false} title="Outils" content={@stronghold.tools} />
          <.bloc_content
            :if={@stronghold.functions}
            underlined?={true}
            title="Bâtiments & Dépendances"
            content={@stronghold.functions}
          />
        </div>
      </div>
    </div>
    """
  end

  defp bloc_content(%{content: _content, underlined?: _underlined?} = assigns) do
    ~H"""
    <div class="p-4 border border-slate-900/80 shadow-lg bg-slate-900/80 backdrop-blur">
      <h2 :if={Map.get(assigns, :title)} class="pb-2 border-b mb-2 border-slate-900/80 font-bold">
        <%= @title %>
      </h2>
      <div class="text-sm space-y-1.5 text-slate-100/80">
        <%= Helper.text_to_raw_html(@content) %>
      </div>
    </div>
    """
  end

  defp leading_zeros(amount) do
    String.pad_leading("", Enum.max([0, 4 - String.length(Integer.to_string(amount))]), "0")
  end

  defp coins_class(:copper), do: "bg-orange-800 border-orange-700 outline-orange-700/10 text-orange-200"
  defp coins_class(:silver), do: "bg-gray-200 border-gray-100 outline-gray-100/10 text-gray-700"
  defp coins_class(:gold), do: "bg-yellow-500 border-yellow-400 outline-yellow-400/10 text-amber-800"
end
