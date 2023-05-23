defmodule ForbiddenLandsWeb.Live.ImportInstance do
  @moduledoc """
  Form to import an instance.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  alias ForbiddenLands.Instances.Instances

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Importer une instance")
      |> assign(changeset: changeset())

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <div class="bg-white text-slate-900 max-w-screen-md mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <h1 class="text-2xl font-bold">Importer une campagne</h1>

      <.simple_form :let={f} as={:create} for={@changeset} phx-submit="save">
        <.input field={{f, :data}} type="textarea" label="Data" />
        <:actions>
          <.button>Créer la campagne</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"create" => params}, socket) do
    with {:ok, data} <- Jason.decode(params["data"]),
         {:ok, _instance} <- Instances.create_from_export(data) do
      {:noreply, push_navigate(socket, to: ~p"/admin")}
    else
      {:error, %Jason.DecodeError{} = _data} ->
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp changeset(params \\ %{}) do
    {%{}, %{data: :string}}
    |> Ecto.Changeset.cast(params, [:data])
    |> Ecto.Changeset.validate_required([:data])
  end
end
