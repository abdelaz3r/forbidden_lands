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
      |> assign(changeset: changeset())
      |> assign(page_title: dgettext("app", "Import an adventure"))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <div class="bg-white text-slate-900 max-w-screen-md mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <h1 class="text-2xl font-bold">
        <%= dgettext("app", "Import an adventure") %>
      </h1>

      <.simple_form :let={f} as={:create} for={@changeset} phx-submit="save">
        <.input
          field={{f, :data}}
          type="textarea"
          label={dgettext("app", "Game data (simply paste the content of the .json file)")}
        />

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
            <%= dgettext("app", "Import the adventure!") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"create" => params}, socket) do
    with {:ok, data} <- Jason.decode(params["data"]),
         data <- Map.put(data, "username", params["username"]),
         data <- Map.put(data, "password", params["password"]),
         {:ok, _instance} <- Instances.create_from_export(data) do
      {:noreply, push_navigate(socket, to: ~p"/#{Gettext.get_locale()}/admin")}
    else
      {:error, %Jason.DecodeError{} = _data} ->
        # TODO: do something with the error
        {:noreply, socket}

      {:error, changeset} ->
        # TODO: do something with the error
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp changeset(params \\ %{}) do
    {%{}, %{data: :string}}
    |> Ecto.Changeset.cast(params, [:data])
    |> Ecto.Changeset.validate_required([:data])
  end
end
