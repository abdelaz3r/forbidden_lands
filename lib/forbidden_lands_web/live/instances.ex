defmodule ForbiddenLandsWeb.Live.Instances do
  @moduledoc """
  Home view.
  List all instances.
  """

  use ForbiddenLandsWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="p-5">
      List des instances
      <.link href={~p"/new"}>
        New
      </.link>
    </div>
    """
  end
end
