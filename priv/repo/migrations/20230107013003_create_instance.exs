defmodule ForbiddenLands.Repo.Migrations.CreateInstance do
  use Ecto.Migration

  def change do
    create(table(:instance)) do
      add(:name, :string, null: false)
      add(:initial_date, :integer, null: false)
      add(:current_date, :integer, null: false)
      add(:stronghold, :map)

      timestamps()
    end
  end
end
