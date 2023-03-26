defmodule ForbiddenLandsWeb.Components.Generic.AudioPlayer do
  @moduledoc false

  use Phoenix.Component

  attr(:playlist, :string, required: true, doc: "todo")
  attr(:playlists, :atom, required: true, doc: "todo")

  @spec audio_player(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def audio_player(assigns) do
    ~H"""
    <.live_component module={__MODULE__.LiveComponent} id="audio-player" playlist={@playlist} playlists={@playlists} />
    """
  end

  defmodule LiveComponent do
    @moduledoc false

    use Phoenix.LiveComponent

    def mount(socket) do
      socket =
        socket
        |> assign(:playing?, false)
        |> assign(:current_music, "")

      {:ok, socket}
    end

    def update(assigns, socket) do
      socket =
        socket
        |> assign(:playlists, assigns.playlists)
        |> assign(:current_playlist, assigns.playlist)
        |> maybe_play_current_playlist()

      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <div phx-hook="audio-player" id="audio-player-hook" class="flex gap-2 items-center">
        <button
          phx-click={if(@playing?, do: "pause", else: "play")}
          phx-target={@myself}
          class="peer transition-all text-slate-100/60 hover:text-slate-100 rounded-full bg-black/20 shadow-2xl shadow-white"
        >
          <Heroicons.play_circle :if={not @playing?} class="w-10 h-10" />
          <Heroicons.pause_circle :if={@playing?} class="w-10 h-10" />
        </button>

        <div
          :if={@playing? && @current_music != ""}
          class="px-2 py-1 bg-slate-900/60 rounded transition-all opacity-0 peer-hover:opacity-100 font-title"
        >
          <%= @current_music %>
        </div>
      </div>
      """
    end

    def handle_event("play", _params, socket) do
      socket =
        socket
        |> assign(:playing?, true)
        |> maybe_play_current_playlist()

      {:noreply, socket}
    end

    def handle_event("pause", _params, socket) do
      socket =
        socket
        |> assign(:playing?, false)
        |> push_event("pause", %{})

      {:noreply, socket}
    end

    def handle_event("audio-ended", _params, socket) do
      {:noreply, maybe_play_current_playlist(socket)}
    end

    defp maybe_play_current_playlist(socket) do
      playlists = socket.assigns.playlists.()

      {playlist, musics} =
        Enum.find(playlists, fn {playlist, _musics} -> playlist == socket.assigns.current_playlist end)

      with true <- length(musics) > 0,
           music <- Enum.random(musics),
           music_url <- "/musics/#{playlist}/#{music}" do
        [music_name, _ext] = String.split(music, ".")
        music_name = String.replace(music_name, "_", " ")

        socket
        |> push_event("play", %{music: music_url})
        |> assign(:current_music, music_name)
      else
        false ->
          socket
          |> push_event("play", %{music: ""})
          |> assign(:current_music, "")

        _ ->
          socket
      end
    end
  end
end
