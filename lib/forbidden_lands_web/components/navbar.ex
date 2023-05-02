defmodule ForbiddenLandsWeb.Components.Navbar do
  @moduledoc """
  """

  use ForbiddenLandsWeb, :html

  @spec navbar(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  def navbar(assigns) do
    ~H"""
    <header class="bg-white text-slate-900 border-b md:border-none py-3 px-2 shadow-md flex justify-between">
      <nav class="flex">
        <h1 class="font-bold py-2 px-3 border-r text-brand">
          FLw
        </h1>
        <.link patch={~p"/"} class={link_classes()}>
          Liste des Aventures
        </.link>
      </nav>

      <nav class="flex">
        <.link patch={~p"/admin"} class={link_classes()}>
          <Heroicons.lock_closed class="w-6 h-6" />
        </.link>
      </nav>
    </header>
    """
  end

  def link_classes(), do: "py-2 px-3 hover:bg-slate-100 rounded"
end
