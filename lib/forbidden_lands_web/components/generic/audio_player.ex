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
        |> assign(:current_mood, "empty")
        |> assign(:current_music, "")

      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <div class="flex gap-2">
        <button phx-click="next" phx-target={@myself}>
          Next music
        </button>

        <div>
          Current: <%= @current_mood %>
        </div>

        <button :for={{mood, _music} <- moods()} phx-click="change-mood" phx-value-mood={mood} phx-target={@myself}>
          <%= mood %>
        </button>

        <div phx-hook="audio-player" id="audio-player-hook" data-source={@current_music}></div>
      </div>
      """
    end

    def handle_event("change-mood", %{"mood" => mood}, socket) do
      socket =
        socket
        |> assign(:current_mood, mood)
        |> next_music()

      {:noreply, socket}
    end

    def handle_event("next", _params, socket) do
      {:noreply, next_music(socket)}
    end

    def handle_event("audio-ended", _params, socket) do
      {:noreply, next_music(socket)}
    end

    defp next_music(socket) do
      {mood, musics} = Enum.find(moods(), fn {mood, _musics} -> mood == socket.assigns.current_mood end)
      music = if length(musics) == 0, do: "", else: "/musics/#{mood}/#{Enum.random(musics)}"

      assign(socket, :current_music, music)
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
