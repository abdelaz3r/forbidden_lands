defmodule ForbiddenLandsWeb.Live.CreateInstance do
  @moduledoc """
  Form to create an instance.
  """

  use ForbiddenLandsWeb, :live_view

  alias ForbiddenLands.Calendar
  alias Ecto.Changeset
  alias ForbiddenLands.Instances.Instances
  alias Phoenix.HTML.Form

  @default_date "1.7.1166"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :changeset, changeset())}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="p-4 md:p-20 min-h-screen bg-slate-700 text-slate-100">
      <div class="md:w-[700px] h-96 p-5 border border-slate-900/50 bg-slate-800 shadow-2xl shadow-black/50">
        <h1 class="pb-5">Nouvelle instance</h1>

        <.form
          :let={f}
          as={:create}
          for={@changeset}
          phx-change="validate"
          phx-submit="save"
          class="flex flex-col gap-3 text-slate-900"
        >
          <input
            type="text"
            placeholder="Name"
            id={Form.input_id(f, :name)}
            name={Form.input_name(f, :name)}
            value={Form.input_value(f, :name)}
          />

          <input
            type="text"
            placeholder="Date (dd.mm.yyyy)"
            id={Form.input_id(f, :date)}
            name={Form.input_name(f, :date)}
            value={Form.input_value(f, :date)}
          />

          <button class="bg-slate-300">Submit</button>
        </.form>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("validate", params, socket) do
    changeset = Map.put(changeset(params["create"]), :action, :validate)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", params, socket) do
    changeset = Map.put(changeset(params["create"]), :action, :update)

    with true <- changeset.valid?,
         {:ok, calendar} <- Calendar.from_date(changeset.changes.date),
         name <- changeset.changes.name,
         quarters <- calendar.count.quarters,
         data <- %{name: name, initial_date: quarters, current_date: quarters},
         {:ok, instance} <- Instances.create(data) do
      {:noreply, push_navigate(socket, to: ~p"/instance/#{instance.id}")}
    else
      false ->
        {:noreply, assign(socket, :changeset, changeset)}

      error ->
        socket =
          socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, inspect(error))

        {:noreply, socket}
    end
  end

  defp changeset(params \\ %{date: @default_date}) do
    types = %{name: :string, date: :string}
    fields = Map.keys(types)

    {%{}, types}
    |> Changeset.cast(params, fields)
    |> Changeset.validate_required([:name, :date])
    |> Changeset.validate_length(:name, max: 200)
  end
end
