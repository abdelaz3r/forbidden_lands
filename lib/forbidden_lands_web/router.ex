defmodule ForbiddenLandsWeb.Router do
  use ForbiddenLandsWeb, :router

  alias ForbiddenLandsWeb.Plugs, as: Plugs

  pipeline(:browser) do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ForbiddenLandsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope("/", ForbiddenLandsWeb.Live) do
    pipe_through(:browser)

    live_session(:public) do
      live("/", Landing)
      live("/adventure/:id", Dashboard)
      live("/adventure/:id/story", Story)
      live("/adventure/:id/story#:anchor", Story)
      live("/adventure/:id/manage", Manage)
      live("/adventure/:id/manage/:panel", Manage)
    end
  end

  scope("/", ForbiddenLandsWeb.Live) do
    pipe_through([:browser, Plugs.AdminAuth])

    live_session(:admin) do
      live("/admin", Admin)
      live("/start-a-new-adventure", CreateInstance)
      live("/import-adventure", ImportInstance)
    end
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:forbidden_lands, :dev_routes) do
    scope "/dev" do
      pipe_through(:browser)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
