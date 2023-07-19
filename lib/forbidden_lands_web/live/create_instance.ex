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
    socket =
      socket
      |> assign(page_title: "Créer une instance")
      |> assign(changeset: Instance.create(%Instance{}, %{human_date: @default_date}))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <div class="bg-white text-slate-900 max-w-screen-md mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <h1 class="text-2xl font-bold">
        Nouvelle campagne
      </h1>

      <.simple_form :let={f} as={:create} for={@changeset} phx-submit="save">
        <.input field={{f, :name}} label="Nom" />
        <.input field={{f, :human_date}} label="Date de départ (dd.mm.yyyy)" />

        <h2 class="pb-3 text-xl font-bold">
          Login pour le maître du jeu
        </h2>

        <div class="grid grid-cols-2 gap-4">
          <.input field={{f, :username}} label="Nom d'utilisateur" />
          <.input field={{f, :password}} type="password" label="Mot de passe" />
        </div>

        <:actions>
          <.button>Créer la campagne</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"create" => params}, socket) do
    case Instances.create(params) do
      {:ok, _instance} ->
        {:noreply, push_navigate(socket, to: ~p"/admin")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
