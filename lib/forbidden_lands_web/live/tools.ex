defmodule ForbiddenLandsWeb.Live.Tools do
  @moduledoc """
  Tools view.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: dgettext("app", "Tools list"))}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <section class="bg-white text-slate-900 max-w-screen-md mx-auto md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-2">
      <h1 class="text-brand font-bold text-xl mb-5">
        <%= dgettext("app", "Tools & Resources") %>
      </h1>

      <div class="grid grid-cols-2 gap-5">
        <.link
          :for={tool <- tools()}
          navigate={tool.link}
          class="block p-5 border border-slate-200 rounded hover:bg-slate-100 transition-all"
        >
          <h2 class="font-bold text-xl pb-2">
            <%= tool.title %>
          </h2>
          <p class="text-slate-900/70">
            <%= tool.desc %>
          </p>
        </.link>
      </div>
    </section>
    """
  end

  defp tools() do
    [
      %{
        link: ~p"/#{Gettext.get_locale()}/tools/spells",
        title: dgettext("app", "Spells list"),
        desc: dgettext("app", "Browse and explore list of spells.")
      },
      %{
        link: ~p"/#{Gettext.get_locale()}/tools/dices",
        title: dgettext("app", "Dices"),
        desc: dgettext("app", "TODO.")
      }
    ]
  end
end
