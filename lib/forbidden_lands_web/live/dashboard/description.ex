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
      "grid grid-cols-3 absolute w-[1000px] bottom-0 top-0 transition-all duration-500 divide-x divide-grey-900",
      if(@open?, do: "right-[400px] opacity-100", else: "right-[-1000px] opacity-50")
    ]}>
      <.column partial?={true}>
        <.bloc_content :if={@stronghold.description} content={@stronghold.description}>
          <%= @stronghold.name %>
        </.bloc_content>
        <.bloc_content :if={@stronghold.items} content={@stronghold.items}>
          <.icon name={:crown} class="w-6 h-6 opacity-50" />
          <span>
            <%= dgettext("app", "Treasure & Possessions") %>
          </span>
        </.bloc_content>
        <.bloc_content :if={@stronghold.tools} content={@stronghold.tools}>
          <.icon name={:hammer} class="w-6 h-6 opacity-50" />
          <span>
            <%= dgettext("app", "Tools") %>
          </span>
        </.bloc_content>
      </.column>
      <.column>
        <.bloc_content :if={@stronghold.hirelings} content={@stronghold.hirelings}>
          <.icon name={:users} class="w-6 h-6 opacity-50" />
          <span>
            <%= dgettext("app", "Hirelings & Followers") %>
          </span>
        </.bloc_content>
      </.column>
      <.column>
        <.bloc_content :if={@stronghold.functions} content={@stronghold.functions}>
          <.icon name={:school} class="w-6 h-6 opacity-50" />
          <span>
            <%= dgettext("app", "Functions") %>
          </span>
        </.bloc_content>
      </.column>
    </div>
    """
  end

  attr(:partial?, :boolean, default: false)
  slot(:inner_block, required: true)

  defp column(assigns) do
    ~H"""
    <div class={["h-screen", not @partial? && "overflow-y-scroll bg-grey-800 shadow-2xl shadow-black/50"]}>
      <div class="flex flex-col justify-end min-h-screen">
        <div class={["py-4", @partial? && "bg-grey-800 border-l border-t border-grey-900 shadow-2xl shadow-black/50"]}>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  attr(:content, :string, required: true)
  slot(:inner_block, required: true)

  defp bloc_content(%{content: _content} = assigns) do
    ~H"""
    <div class="px-4">
      <h2 :if={render_slot(@inner_block) != []} class="flex items-center gap-2 pt-4 text-xl first-letter:text-2xl font-bold">
        <%= render_slot(@inner_block) %>
      </h2>
      <div class="text-sm font-sans divide-y divide-grey-900/50 text-grey-100/80">
        <%= Helper.text_to_raw_html(@content, "py-3") %>
      </div>
    </div>
    """
  end
end
