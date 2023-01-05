defmodule ForbiddenLandsWeb.Live.Instance do
  @moduledoc """
  Home view
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Generic.Button
  import ForbiddenLandsWeb.Live.Instance.Header

  alias ForbiddenLands.Calendar

  @current_quarter 1_701_993

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    now = Calendar.from_quarters(@current_quarter)
    quarter_shift = now.count.quarters - rem(now.count.quarters - 1, 4)

    socket =
      socket
      |> assign(now: now)
      |> assign(quarter_shift: quarter_shift)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-[1fr_400px] h-screen bg-slate-700">
      <div class="flex items-stretch">
        <div class="grow m-6 border border-white/20 border-dashed rounded-lg flex justify-center items-center">
          <h1 class="font-title font-bold text-4xl text-white/20">
            Carte des Forbidden Lands
          </h1>
        </div>
      </div>

      <div class="flex flex-col overflow-hidden bg-slate-800 shadow-xl shadow-black/50">
        <.header date={@now} quarter_shift={@quarter_shift} class="flex-none z-10" />

        <div class="grow overflow-y-auto flex flex-col gap-5 p-5">
          <div class="text-slate-400">
            <%= inspect(@now) %>
          </div>

          <div class="flex flex-wrap gap-2">
            <.button
              :for={amount <- [1, 4, 28, 180, 1460, -1, -4, -28, -180, -1460]}
              phx-click="move"
              phx-value-amount={amount}
              phx-value-type="quarter"
              style={:secondary}
            >
              <%= amount %> Quarter
            </.button>
          </div>

          <div class="text-slate-400">
            <%= inspect(@now) %>
          </div>
        </div>

        <div class="flex-none h-40 font-title text-slate-100 border-t border-slate-900 shadow-2xl shadow-black/60">
          Castle info
        </div>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("move", %{"amount" => amount, "type" => type}, socket) do
    amount = String.to_integer(amount)
    type = String.to_existing_atom(type)

    {:noreply, assign(socket, now: Calendar.add(socket.assigns.now, amount, type))}
  end
end
