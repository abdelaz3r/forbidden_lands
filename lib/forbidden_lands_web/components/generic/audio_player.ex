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
        |> assign(:playing?, false)
        |> assign(:current_mood, "empty")

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
          Current: <%= @current_mood %>
        </div>

        <button :for={{mood, _music} <- moods()} phx-click="change-mood" phx-value-mood={mood} phx-target={@myself}>
          <%= mood %>
        </button>
      </div>
      """
    end

    def handle_event("play", _params, socket) do
      socket =
        socket
        |> assign(:playing?, true)
        |> play_current_mood()

      {:noreply, socket}
    end

    def handle_event("pause", _params, socket) do
      socket =
        socket
        |> assign(:playing?, false)
        |> push_event("pause", %{})

      {:noreply, socket}
    end

    def handle_event("change-mood", %{"mood" => mood}, socket) do
      socket =
        socket
        |> assign(:current_mood, mood)
        |> play_current_mood()

      {:noreply, socket}
    end

    def handle_event("audio-ended", _params, socket) do
      {:noreply, play_current_mood(socket)}
    end

    defp play_current_mood(socket) do
      {mood, musics} = Enum.find(moods(), fn {mood, _musics} -> mood == socket.assigns.current_mood end)
      music = if length(musics) == 0, do: "", else: "/musics/#{mood}/#{Enum.random(musics)}"

      push_event(socket, "play", %{music: music})
    end

    defp moods() do
      %{
        "empty" => [],
        "noises" => ["test1.mp3", "test2.mp3", "test3.mp3"],
        "musics" => ["music1.mp3", "music2.mp3"]
      }
    end
  end
end
