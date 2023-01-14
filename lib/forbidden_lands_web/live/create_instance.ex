defmodule ForbiddenLandsWeb.Live.CreateInstance do
  @moduledoc """
  Form to create an instance.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Instances.Instance
  alias ForbiddenLands.Instances.Instances

  @default_date "1.7.1166"

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
    <div class="p-5 md:p-20 min-h-screen bg-slate-700">
      <div class="md:w-[700px] p-5 border border-slate-900/50 bg-slate-800 shadow-2xl shadow-black/50">
        <h1 class="pb-5 text-2xl font-bold font-title">Nouvelle campagne</h1>

        <.simple_form :let={f} as={:create} for={@changeset} phx-submit="save">
          <.input field={{f, :name}} label="Nom" />
          <.input field={{f, :human_date}} label="Date de départ (dd.mm.yyyy)" />
          <:actions>
            <.button>Créer la campagne</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"create" => params}, socket) do
    case Instances.create(params) do
      {:ok, instance} ->
        {:noreply, push_navigate(socket, to: ~p"/instance/#{instance.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
