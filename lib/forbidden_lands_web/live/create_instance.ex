defmodule ForbiddenLandsWeb.Live.CreateInstance do
  @moduledoc """
  Form to create an instance.
  """

  use ForbiddenLandsWeb, :live_view

  # @current_quarter 1_701_993

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
      Form pour créer des instances
    </div>
    """
  end
end
