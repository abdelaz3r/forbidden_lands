defmodule ForbiddenLandsWeb.Live.Home do
  @moduledoc """
  Home view
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
    Home
    """
  end
end
