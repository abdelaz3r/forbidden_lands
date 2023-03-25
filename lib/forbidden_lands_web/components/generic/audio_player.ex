defmodule ForbiddenLandsWeb.Components.Generic.AudioPlayer do
  @moduledoc false

  use Phoenix.Component

  # attr(:path, :string, required: true, doc: "path to the audio file")

  @spec audio_player(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def audio_player(assigns) do
    ~H"""
    <.live_component module={__MODULE__.LiveComponent} id="audio-player" />
    """
  end

  defmodule LiveComponent do
    @moduledoc false

    use Phoenix.LiveComponent

    def mount(socket) do
      socket =
        socket
        |> assign(:musics, musics())
        |> assign(:current_music, 0)

      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <div class="">
        <div phx-hook="audio-player" id="audio-player-hook" data-source={Enum.at(assigns.musics, assigns.current_music)}></div>

        <button phx-click="next" phx-target={@myself}>
          Next
        </button>
      </div>
      """
    end

    def handle_event("next", _params, socket) do
      {:noreply, next_music(socket)}
    end

    def handle_event("audio-ended", _params, socket) do
      {:noreply, next_music(socket)}
    end

    defp next_music(socket) do
      assign(socket, :current_music, rem(socket.assigns.current_music + 1, length(socket.assigns.musics)))
    end

    defp musics() do
      [
        "test1.mp3",
        "test2.mp3",
        "test3.mp3"
      ]
      |> Enum.map(fn music -> "/musics/#{music}" end)
    end
  end
end
