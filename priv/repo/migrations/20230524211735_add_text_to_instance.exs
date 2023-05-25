defmodule ForbiddenLands.Repo.Migrations.AddTextToInstance do
  use Ecto.Migration

  def change do
    alter(table(:instances)) do
      add(:description, :text)
      add(:prepend_name, :text)
      add(:append_name, :text)
      add(:introduction, :text)
    end
  end
end
