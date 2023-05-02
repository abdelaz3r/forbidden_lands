defmodule ForbiddenLandsWeb.Plugs.AdminAuth do
  @moduledoc """
  Plug to authenticate admin users.
  """

  def init(options), do: options

  def call(conn, _opts) do
    username = Application.fetch_env!(:forbidden_lands, :username)
    password = Application.fetch_env!(:forbidden_lands, :password)

    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
