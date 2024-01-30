defmodule ForbiddenLandsWeb.Live.About do
  @moduledoc """
  About view.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: dgettext("app", "Forbidden Lands Companion"))}
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
      <h1 class="font-bold text-2xl mb-5">
        <%= dgettext("app", "Welcome!") %>
      </h1>

      <%= dgettext("app", "Landing HTML text") |> raw() %>
    </section>
    """
  end
end
