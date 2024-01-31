defmodule ForbiddenLandsWeb.Live.CreateInstance do
  @moduledoc """
  Form to create an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  alias ForbiddenLands.Instances.Instance
  alias ForbiddenLands.Instances.Instances

  @default_date "1.4.1165"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    base_instance = Instance.create(%{human_date: @default_date})

    socket =
      socket
      |> assign(changeset: base_instance)
      |> assign(page_title: dgettext("app", "Create an adventure"))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <div class="bg-white text-slate-900 max-w-screen-md mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <h1 class="text-2xl font-bold">
        <%= dgettext("app", "Create an adventure") %>
      </h1>

      <.simple_form :let={f} as={:create} for={@changeset} phx-submit="save">
        <.input field={{f, :name}} label={dgettext("app", "Name")} />

        <div class="grid grid-cols-2 gap-4">
          <.input field={{f, :human_date}} label={dgettext("app", "Start date (dd.mm.yyyy)")} />
          <.input field={{f, :theme}} type="select" options={Instance.themes()} label={dgettext("app", "Theme")} />
        </div>

        <h2 class="pb-1 text-xl font-bold">
          <%= dgettext("app", "Game master credentials") %>
        </h2>

        <p class="pb-3 opacity-70">
          <%= dgettext("app", "You will be asked for these to access the game master area.") %>
        </p>

        <div class="grid grid-cols-2 gap-4">
          <.input field={{f, :username}} label={dgettext("app", "Username")} />
          <.input field={{f, :password}} type="password" label={dgettext("app", "Password")} />
        </div>

        <:actions>
          <.button>
            <%= dgettext("app", "May the adventure start!") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"create" => params}, socket) do
    case Instances.create(params) do
      {:ok, _instance} ->
        {:noreply, push_navigate(socket, to: ~p"/#{Gettext.get_locale()}/admin")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
