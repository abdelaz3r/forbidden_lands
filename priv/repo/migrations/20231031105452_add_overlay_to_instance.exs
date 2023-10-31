defmodule ForbiddenLands.Repo.Migrations.AddOverlayToInstance do
  use Ecto.Migration

  def change do
    alter(table(:instances)) do
      add(:overlay, :string, null: true)
    end
  end
end
