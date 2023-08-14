defmodule ForbiddenLandsWeb.Plugs.EnsureLocale do
  @moduledoc """
  Plug to ensure a locale is passed into the app.
  """

  alias Phoenix.Controller

  def init(options), do: options

  def call(%{path_params: %{"locale" => locale}} = conn, _opts) do
    available_locales = Gettext.known_locales(ForbiddenLandsWeb.Gettext)

    # TODO: have a closer look at this.
    # Bug on redirect, maybe only in dev mode, maybe related to livereload.
    if locale in available_locales,
      do: conn,
      else: Controller.redirect(conn, to: "/en")
  end

  def call(conn, _opts) do
    Controller.redirect(conn, to: "/en")
  end
end
