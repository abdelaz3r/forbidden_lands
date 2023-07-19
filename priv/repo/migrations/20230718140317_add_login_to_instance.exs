defmodule ForbiddenLands.Repo.Migrations.AddLoginToInstance do
  use Ecto.Migration

  def change do
    alter(table(:instances)) do
      add(:username, :text)
      add(:hashed_password, :text)
    end
  end
end
