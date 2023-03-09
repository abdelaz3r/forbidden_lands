defmodule ForbiddenLandsWeb.Router do
  use ForbiddenLandsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ForbiddenLandsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ForbiddenLandsWeb.Live do
    pipe_through(:browser)

    live("/", Instances)
    live("/instance/new", CreateInstance)
    live("/instance/:id/dashboard", Dashboard)
    live("/instance/:id/story", Story)
    live("/instance/:id/admin", Admin)
    live("/instance/:id/admin/:panel", Admin)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:forbidden_lands, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: ForbiddenLandsWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
