defmodule ForbiddenLands.Repo.Migrations.CreateInstance do
  use Ecto.Migration

  def change do
    create(table(:instances)) do
      add(:name, :string, null: false)
      add(:initial_date, :integer, null: false)
      add(:current_date, :integer, null: false)
      add(:stronghold, :map)

      timestamps()
    end

    create(table(:events)) do
      add(:date, :integer, null: false)
      add(:type, :string, null: false)
      add(:title, :string, null: false)
      add(:description, :text, null: false)
      add(:instance_id, references(:instances, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
