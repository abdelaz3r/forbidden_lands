defmodule ForbiddenLandsWeb.Live.Dashboard.Description do
  @moduledoc """
  TODO.
  """

  use ForbiddenLandsWeb, :html

  attr(:stronghold, :map, required: true, doc: "todo")
  attr(:open?, :boolean, required: true, doc: "todo")
  attr(:class, :string, default: "", doc: "todo")

  @spec description(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def description(assigns) do
    ~H"""
    <div class={[
      "grid grid-cols-3 absolute w-[1000px] bottom-0 top-0 transition-all duration-500 divide-x divide-slate-900",
      if(@open?, do: "right-[400px] opacity-100", else: "right-[-1000px] opacity-50")
    ]}>
      <.column partial?={true}>
        <.bloc_content :if={@stronghold.description} title={@stronghold.name} content={@stronghold.description} />
        <.bloc_content :if={@stronghold.items} title="Trésor & Possessions" content={@stronghold.items} />
        <.bloc_content :if={@stronghold.tools} title="Outils" content={@stronghold.tools} />
      </.column>
      <.column>
        <.bloc_content :if={@stronghold.hirelings} title="Gardes & Employés" content={@stronghold.hirelings} />
      </.column>
      <.column>
        <.bloc_content :if={@stronghold.functions} title="Bâtiments & Dépendances" content={@stronghold.functions} />
      </.column>
    </div>
    """
  end

  attr(:partial?, :boolean, default: false, doc: "todo")
  slot(:inner_block, required: true, doc: "todo")

  defp column(assigns) do
    ~H"""
    <div class={["h-screen", not @partial? && "overflow-y-scroll bg-slate-800 shadow-2xl shadow-black/50"]}>
      <div class="flex flex-col justify-end min-h-screen">
        <div class={["py-4", @partial? && "bg-slate-800 border-l border-t border-slate-900 shadow-2xl shadow-black/50"]}>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  defp bloc_content(%{content: _content} = assigns) do
    ~H"""
    <div class="px-4">
      <h2 :if={Map.get(assigns, :title)} class="pt-4 text-xl first-letter:text-2xl font-title font-bold">
        <%= @title %>
      </h2>
      <div class="text-sm divide-y divide-slate-900/50 text-slate-100/80">
        <%= Helper.text_to_raw_html(@content) %>
      </div>
    </div>
    """
  end
end
