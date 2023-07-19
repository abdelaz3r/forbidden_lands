defmodule ForbiddenLandsWeb.Plugs.UserAuth do
  @moduledoc """
  Plug to authenticate users.
  """

  alias Plug.{BasicAuth, Conn}
  alias ForbiddenLands.Instances.{Instance, Instances}
  alias Phoenix.Controller

  def init(options), do: options

  def call(%{path_params: %{"id" => id}} = conn, _opts) do
    with {username, password} <- BasicAuth.parse_basic_auth(conn),
         {:ok, instance} <- Instances.get(id, 0),
         true <- Instance.verify_credential(instance, username, password) do
      conn
    else
      false ->
        conn
        |> BasicAuth.request_basic_auth()
        |> Conn.halt()

      :error ->
        conn
        |> BasicAuth.request_basic_auth()
        |> Conn.halt()

      {:error, _reason} ->
        conn
        |> Controller.put_flash(:info, "Aventure introuvable")
        |> Controller.redirect(to: "/")
    end
  end

  def call(conn, _opts) do
    Controller.redirect(conn, to: "/")
  end
end
