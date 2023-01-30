defmodule ForbiddenLandsWeb.Live.Dashboard.Stronghold do
  @moduledoc """
  TODO.
  """

  use ForbiddenLandsWeb, :html

  alias ForbiddenLands.Instances.Stronghold

  attr(:stronghold, :map, required: true, doc: "todo")
  attr(:class, :string, default: "", doc: "todo")

  @spec stronghold(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def stronghold(assigns) do
    ~H"""
    <div
      :if={@stronghold}
      class={[
        "flex-none font-title border-t border-slate-900 shadow-2xl shadow-black/50 bg-gradient-to-l from-slate-800",
        "to-slate-900 overflow-hidden h-[144px] hover:h-[434px] transition-all duration-500",
        @class
      ]}
    >
      <div class="p-4">
        <h1 class="flex gap-4 text-lg font-bold pb-4">
          <Heroicons.bookmark class="w-6" />
          <%= @stronghold.name %>
        </h1>

        <div class="flex gap-8 border border-slate-900/80 py-2 px-4 bg-slate-900/50 justify-around mb-4">
          <div :for={type <- [:copper, :silver, :gold]} class="flex items-center w-20 flex-none">
            <Heroicons.circle_stack class={[
              "float-left w-8 my-2 mr-3 p-1.5 rounded-full border outline outline-offset-2 outline-2",
              coins_class(type)
            ]} />
            <span class="text-xl font-bold">
              <%= Stronghold.coins_to_type(@stronghold.coins, type) %>
            </span>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-1">
          <div :for={type <- Stronghold.resource_fields()} :if={type != :coins}>
            <span class="font-bold">
              <%= Map.get(@stronghold, type) %>
            </span>
            <span class="text-slate-100/60">
              <%= Stronghold.resource_name(type, Map.get(@stronghold, type)) %>
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp coins_class(:copper), do: "bg-orange-800 border-orange-700 outline-orange-700/10 text-orange-200"
  defp coins_class(:silver), do: "bg-gray-200 border-gray-100 outline-gray-100/10 text-gray-700"
  defp coins_class(:gold), do: "bg-yellow-500 border-yellow-400 outline-yellow-400/10 text-amber-800"
end
