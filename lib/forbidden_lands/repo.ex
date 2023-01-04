defmodule ForbiddenLands.Repo do
  use Ecto.Repo,
    otp_app: :forbidden_lands,
    adapter: Ecto.Adapters.Postgres
end
