defmodule ForbiddenLands.Repo.Migrations.AddMoodToInstance do
  use Ecto.Migration

  def change do
    alter(table(:instances)) do
      add(:mood, :string, null: false, default: "silence")
    end
  end
end
