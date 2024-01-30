defmodule ForbiddenLandsWeb.Live.Tools.Dices do
  @moduledoc """
  Dices view.
  """

  use ForbiddenLandsWeb, :live_view

  import ForbiddenLandsWeb.Components.Navbar

  alias ForbiddenLands.Tools.Dice

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: dgettext("app", "Dices simulator"))}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _uri, socket) do
    data_types =
      Enum.map(Dice.types(), fn type ->
        type
        |> Dice.data_type()
        |> Map.merge(%{count: 0})
      end)

    socket =
      socket
      |> assign(:data_types, data_types)
      |> assign(:rolls, [])

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.navbar />

    <section class="bg-white text-stone-900 max-w-screen-md mx-auto md:my-10 md:shadow-md md:rounded overflow-hidden p-5 space-y-5">
      <h1 class="text-brand font-bold text-xl">
        <%= dgettext("app", "Dice launcher") %>
      </h1>

      <div>
        <h2 class="font-bold mb-2">
          <%= dgettext("app", "Set dices for launch") %>
        </h2>

        <div
          :for={%{key: key, base: base, name: name, max: max, count: count} <- @data_types}
          class="flex gap-2 items-top border-t py-2 my-0"
        >
          <h2 class="flex-none w-16 text-xs pt-1">
            <%= name %>
          </h2>
          <div class="flex gap-2 flex-wrap">
            <button class={[dice_style(), dice_style(key)]} phx-click="set-dices" phx-value-key={key} phx-value-count={0}>
              <.icon name={:circle_slash} class="h-6 w-6" />
            </button>
            <%= for i <- 1..max do %>
              <div :if={rem(i, 3) == 1} class="border-l border-stone-100"></div>
              <button
                :if={count >= i}
                class={[dice_style(), dice_style(key)]}
                phx-click="set-dices"
                phx-value-key={key}
                phx-value-count={i}
              >
                <div class="flex items-baseline">
                  <span class="text-xs">D</span>
                  <span><%= base %></span>
                </div>
              </button>
              <button :if={count < i} class={[number_style()]} phx-click="set-dices" phx-value-key={key} phx-value-count={i}>
                <%= i %>
              </button>
            <% end %>
          </div>
        </div>
      </div>

      <div class="flex gap-2">
        <.button phx-click="roll" color={:blue}>
          <%= dgettext("app", "Roll the dices") %>
        </.button>
        <.button phx-click="clear">
          <%= dgettext("app", "Clear the board") %>
        </.button>
      </div>

      <div class="space-y-5">
        <div :for={%{id: id, normal: normal, pushed: pushed} <- @rolls} class="border bg-stone-100/20 rounded shadow">
          <div
            :for={{type, roll} <- [{:normal, normal}, {:pushed, pushed}]}
            :if={roll}
            class={[
              "relative flex flex-col gap-1 p-2",
              type == :normal && "flex-col pt-1.5",
              type == :pushed && "flex-col-reverse border-t border-dashed pb-1.5",
              type == :normal and not is_nil(pushed) && "opacity-60"
            ]}
          >
            <div class="flex justify-between">
              <div class="flex gap-4">
                <span class={roll.success > 0 && "font-bold"}>
                  <%= dgettext("app", "%{count} success", count: roll.success) %>
                </span>
                <span class={type == :pushed and roll.fail_base > 0 && "font-bold"}>
                  <%= dgettext("app", "%{count} failed attribute", count: roll.fail_base) %>
                </span>
                <span class={type == :pushed and roll.fail_gear > 0 && "font-bold"}>
                  <%= dgettext("app", "%{count} failed gear", count: roll.fail_gear) %>
                </span>
              </div>

              <button
                :if={type == :normal and is_nil(pushed)}
                phx-click="push"
                phx-value-id={id}
                class="absolute top-0 right-0 px-2 border-b border-l rounded-bl hover:bg-stone-100 transition"
              >
                <%= dgettext("app", "Push the roll") %>
              </button>
            </div>
            <div :if={roll.dices} class="flex gap-2 flex-wrap">
              <div
                :for={dice <- roll.dices}
                class={[
                  "relative",
                  dice_style(),
                  dice_style(dice.key),
                  not Dice.is_locked(dice) and type == :normal && "border-dashed"
                ]}
              >
                <span class="absolute -top-0.5 right-1">
                  <%= dice.roll %>
                </span>
                <span class="absolute bottom-0.5 left-0.5 flex justify-between">
                  <.icon :if={Dice.fail_count(dice) > 0} name={:skull} class="h-4 w-4 " />
                  <span :if={Dice.success_count(dice) > 0} class="flex gap-0 items-center font-normal">
                    <.icon name={:swords} class="h-4 w-4" />
                    <span :if={Dice.success_count(dice) >= 2} class="text-xs opacity-50">
                      x<%= Dice.success_count(dice) %>
                    </span>
                  </span>
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("set-dices", %{"key" => key, "count" => count}, socket) do
    count = String.to_integer(count)
    key = String.to_existing_atom(key)

    data_types =
      Enum.map(socket.assigns.data_types, fn type ->
        if type.key == key, do: %{type | count: count}, else: type
      end)

    {:noreply, assign(socket, :data_types, data_types)}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, assign(socket, :rolls, [])}
  end

  def handle_event("roll", _params, socket) do
    dices =
      socket.assigns.data_types
      |> Enum.map(fn %{key: key, count: count} ->
        Enum.map(List.duplicate(0, count), fn _ -> key |> Dice.new() |> Dice.roll() end)
      end)
      |> List.flatten()

    {fail_base, fail_gear, success} =
      Enum.reduce(dices, {0, 0, 0}, fn dice, {fail_base, fail_gear, success} ->
        {fail_base + Dice.fail_base_count(dice), fail_gear + Dice.fail_gear_count(dice),
         success + Dice.success_count(dice)}
      end)

    roll = %{
      id: Ecto.UUID.bingenerate() |> Ecto.UUID.cast!(),
      normal: %{
        dices: dices,
        fail_base: fail_base,
        fail_gear: fail_gear,
        success: success
      },
      pushed: nil
    }

    {:noreply, assign(socket, :rolls, [roll | socket.assigns.rolls])}
  end

  def handle_event("push", %{"id" => id}, socket) do
    roll = Enum.find(socket.assigns.rolls, fn roll -> roll.id == id end)
    dices = Enum.map(roll.normal.dices, fn dice -> Dice.roll(dice) end)

    {fail_base, fail_gear, success} =
      Enum.reduce(dices, {0, 0, 0}, fn dice, {fail_base, fail_gear, success} ->
        {fail_base + Dice.fail_base_count(dice), fail_gear + Dice.fail_gear_count(dice),
         success + Dice.success_count(dice)}
      end)

    roll = %{
      roll
      | pushed: %{
          dices: dices,
          fail_base: fail_base,
          fail_gear: fail_gear,
          success: success
        }
    }

    rolls = Enum.map(socket.assigns.rolls, fn r -> if r.id == id, do: roll, else: r end)

    {:noreply, assign(socket, :rolls, rolls)}
  end

  defp number_style(),
    do: "w-10 h-10 font-bold flex items-center justify-center rounded opacity-5 hover:opacity-50 transition"

  defp dice_style(), do: "w-10 h-10 border-2 rounded font-bold flex items-center justify-center"
  defp dice_style(:base), do: "bg-stone-100 border-stone-300 text-stone-600"
  defp dice_style(:skill), do: "bg-red-400 border-red-700 text-red-900"
  defp dice_style(:gear), do: "bg-yellow-400 border-yellow-600 text-yellow-900"
  defp dice_style(:artifact_8), do: "bg-green-400 border-green-700 text-green-900"
  defp dice_style(:artifact_10), do: "bg-teal-400 border-teal-700 text-teal-900"
  defp dice_style(:artifact_12), do: "bg-sky-400 border-sky-700 text-sky-900"
end
