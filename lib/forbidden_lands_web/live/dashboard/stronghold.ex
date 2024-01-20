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
    <section
      :if={@stronghold}
      class={[
        "flex-none border-t border-grey-900 shadow-2xl shadow-black/50 bg-gradient-to-l from-grey-800",
        "to-grey-900 transition-all duration-500 relative",
        if(@open?, do: "h-[458px]", else: "h-[140px]"),
        @class
      ]}
    >
      <button type="button" class="absolute -top-10 w-full p-2" phx-click="toggle_stronghold">
        <.icon name={:chevrons_up} class={"h-6 w-6 m-auto transition-all duration-500 #{@open? && "rotate-180"}"} />
      </button>

      <div class="p-4">
        <header class="flex justify-between text-lg font-bold pb-4">
          <h1 class="flex items-center gap-2">
            <.icon name={:castle} class="w-5 h-5" />
            <%= @stronghold.name %>
          </h1>
          <div class="flex items-center gap-1">
            <%= @stronghold.defense %>
            <.icon name={:shield} class="w-5 h-5" />
          </div>
        </header>

        <div class="flex gap-4 mb-4">
          <div class="flex grow gap-2 border border-grey-800 p-4 bg-grey-900/60 justify-around">
            <div :for={type <- [:copper, :silver, :gold]} class="flex gap-2 items-center flex-none">
              <.icon
                name={:coins}
                class={"float-left w-7 h-7 p-1 rounded-full border outline outline-offset-2 outline-2 #{coins_class(type)}"}
              />
              <span class="font-bold text-lg">
                <%= Stronghold.coins_to_type(@stronghold.coins, type) %>
              </span>
            </div>
          </div>
          <div class="border border-grey-800 py-2 px-4 bg-grey-900/60 justify-around flex gap-2 items-center flex-none">
            <.icon
              name={:message_circle}
              class="float-left w-7 h-7 p-1 rounded-full border outline outline-offset-2 outline-2 bg-cyan-200 border-cyan-100 outline-cyan-100/10 text-cyan-700"
            />
            <span class="text-xl font-bold">
              <%= @stronghold.reputation %>
            </span>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-1 tabular-nums">
          <div :for={type <- Stronghold.resource_fields()} :if={type != :coins} class="flex gap-1 items-baseline">
            <span class="inline-flex font-bold items-baseline">
              <span class="text-grey-100/10"><%= leading_zeros(Map.get(@stronghold, type)) %></span>
              <%= Enum.min([9999, Map.get(@stronghold, type)]) %>
            </span>
            <span class="text-grey-100/60 text-sm truncate">
              <%= Stronghold.resource_name(type, Map.get(@stronghold, type)) %>
            </span>
          </div>
        </div>
      </div>
    </section>
    """
  end

  defp leading_zeros(amount) do
    String.pad_leading("", Enum.max([0, 4 - String.length(Integer.to_string(amount))]), "0")
  end

  defp coins_class(:copper), do: "bg-orange-800 border-orange-700 outline-orange-700/10 text-orange-200"
  defp coins_class(:silver), do: "bg-gray-200 border-gray-100 outline-gray-100/10 text-gray-700"
  defp coins_class(:gold), do: "bg-yellow-500 border-yellow-400 outline-yellow-400/10 text-amber-800"
end
