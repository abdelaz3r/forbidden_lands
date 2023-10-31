defmodule ForbiddenLands.Repo.Migrations.AddMediasToInstance do
  use Ecto.Migration

  def change do
    alter(table(:instances)) do
      add(:medias, :map)
    end
  end
end
