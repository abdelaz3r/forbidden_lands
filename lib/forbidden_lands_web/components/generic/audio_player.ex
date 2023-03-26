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
      {:ok, assign(socket, :playing?, false)}
    end

    def update(assigns, socket) do
      socket =
        socket
        |> assign(:playlists, assigns.playlists)
        |> assign(:current_playlist, assigns.playlist)
        |> play_current_playlist()

      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <div phx-hook="audio-player" id="audio-player-hook" class="flex gap-2">
        <button :if={@playing?} phx-click="pause" phx-target={@myself}>
          Pause
        </button>
        <button :if={not @playing?} phx-click="play" phx-target={@myself}>
          Play
        </button>

        <div>
          Current: <%= @current_playlist %>
        </div>
      </div>
      """
    end

    def handle_event("play", _params, socket) do
      socket =
        socket
        |> assign(:playing?, true)
        |> play_current_playlist()

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
      {:noreply, play_current_playlist(socket)}
    end

    defp play_current_playlist(socket) do
      playlists = socket.assigns.playlists.()

      {playlist, musics} =
        Enum.find(playlists, fn {playlist, _musics} -> playlist == socket.assigns.current_playlist end)

      music = if length(musics) == 0, do: "", else: "/musics/#{playlist}/#{Enum.random(musics)}"

      if socket.assigns.playing? do
        push_event(socket, "play", %{music: music})
      else
        socket
      end
    end
  end
end
