defmodule ForbiddenLands.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ForbiddenLandsWeb.Telemetry,
      # Start the Ecto repository
      ForbiddenLands.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ForbiddenLands.PubSub},
      # Start Finch
      {Finch, name: ForbiddenLands.Finch},
      # Start the Endpoint (http/https)
      ForbiddenLandsWeb.Endpoint
      # Start a worker by calling: ForbiddenLands.Worker.start_link(arg)
      # {ForbiddenLands.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ForbiddenLands.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    ForbiddenLandsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
