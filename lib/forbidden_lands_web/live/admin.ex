defmodule ForbiddenLandsWeb.Live.Admin do
  @moduledoc """
  Admin view.
  """

  use ForbiddenLandsWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    username = Application.fetch_env!(:forbidden_lands, :username)
    password = Application.fetch_env!(:forbidden_lands, :password)

    socket =
      socket
      |> assign(username: username)
      |> assign(password: password)
      |> assign(page_title: "Admin")

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-white text-slate-900 max-w-[700px] mx-auto min-h-screen md:min-h-fit md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      Username: <%= @username %>
      Password: <%= @password %>
    </div>
    """
  end
end
