defmodule ForbiddenLands.Repo.Migrations.AddThemeToInstance do
  use Ecto.Migration

  def change do
    alter(table(:instances)) do
      add(:theme, :string, null: false, default: "forbidden_lands")
    end
  end
end
