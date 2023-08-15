defmodule ForbiddenLandsWeb.Live.Dashboard.Timeline do
  @moduledoc """
  TODO.
  """

  use ForbiddenLandsWeb, :html

  alias ForbiddenLands.Calendar
  alias ForbiddenLands.Instances.Event

  attr(:instance_id, :integer, required: true, doc: "todo")
  attr(:events, :map, required: true, doc: "todo")
  attr(:class, :string, default: "", doc: "todo")

  @spec timeline(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def timeline(assigns) do
    ~H"""
    <div class="grow overflow-y-auto flex flex-col gap-1.5 py-4 font-title">
      <section :for={event <- @events} class="space-y-2">
        <header class="px-4">
          <.icon name={Event.icon_by_type(event.type)} class={event_type_class(event.type)} />
          <h2 class="font-bold"><%= event.title %></h2>
          <.event_date date={event.date} />
        </header>
        <div :if={not is_nil(event.description)} class="text-sm space-y-1.5 px-4 text-slate-100/80">
          <%= Helper.text_to_raw_html(event.description) |> raw() %>
        </div>
        <hr class="border-t border-slate-900/50" />
      </section>

      <div :if={length(@events) == 0} class="p-16 text-center font-title text-lg text-slate-100/40">
        <%= dgettext("app", "Start writing your story.") %>
      </div>

      <.link
        :if={length(@events) > 0}
        navigate={~p"/#{Gettext.get_locale()}/adventure/#{@instance_id}/story"}
        class="px-16 py-10 text-center font-title text-lg text-slate-100/40 hover:text-slate-100 transition-all"
      >
        <%= dgettext("app", "The rest of the story is here!") %>
      </.link>
    </div>
    """
  end

  defp event_date(%{date: date} = assigns) do
    assigns = assign(assigns, calendar: Calendar.from_quarters(date))

    ~H"""
    <div class="text-sm">
      <%= @calendar.month.day %>
      <%= @calendar.month.name %>
      <span class="opacity-60">
        <%= @calendar.year.number %>,
        <span class="opacity-60">
          <%= @calendar.quarter.name %>
        </span>
      </span>
    </div>
    """
  end

  defp event_type_class(:automatic), do: "#{event_icon_class()} bg-gray-500 border-gray-400 outline-gray-400/10"
  defp event_type_class(:normal), do: "#{event_icon_class()} bg-gray-500 border-gray-400 outline-gray-400/20"

  defp event_type_class(:special),
    do: "#{event_icon_class()} bg-emerald-600 border-emerald-400 outline-emerald-500/30"

  defp event_type_class(:legendary), do: "#{event_icon_class()} bg-amber-600 border-amber-400 outline-amber-500/40"
  defp event_type_class(:death), do: "#{event_icon_class()} bg-purple-900 border-purple-700 outline-purple-800/40"

  defp event_icon_class(),
    do: "float-left w-8 h-8 my-2 mr-3 p-1.5 rounded-full border outline outline-offset-2 outline-2"
end
