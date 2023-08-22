defmodule ForbiddenLandsWeb.Plugs.EnsureLocale do
  @moduledoc """
  Plug to ensure a locale is passed into the app.
  """

  alias Phoenix.Controller

  def init(options), do: options

  def call(%{path_params: %{"locale" => locale}} = conn, _opts) do
    available_locales = Gettext.known_locales(ForbiddenLandsWeb.Gettext)

    if locale in available_locales,
      do: conn,
      else: redirect_to_default_locale(conn)
  end

  def call(conn, _opts) do
    redirect_to_default_locale(conn)
  end

  defp redirect_to_default_locale(conn) do
    default_locale = Gettext.get_locale(ForbiddenLandsWeb.Gettext)

    conn
    |> Plug.Conn.halt()
    |> Controller.redirect(to: "/#{default_locale}")
  end
end
